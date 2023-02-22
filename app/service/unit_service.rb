require 'action_controller'
require 'logger'
require 'ulid'

module UnitService

  def self.logger
    Rails.logger
  end

  def self.get_lvl_1_units
    Unit.where(:level => 1)
  end

  def self.get_lvl_2_units(parent_id)
    Unit.where(:level => 2, :parent_id => parent_id)
  end

  def self.get_lvl_3_units(parent_id)
    Unit.where(:level => 3, :parent_id => parent_id)
  end

  # @param id [ActionController::Parameters]
  def self.get_unit_by_id(id)
    Unit.find(id)
  end

  # @param params [ActionController::Parameters]
  def self.get_units_by_conditions(params)
    rs = Unit.all
    page = 0
    size = 10
    %w[id code level].each do |field|
      if params.has_key?(field)
        rs = rs.where(["%s = '%s'", field, params[field]])
      end
    end

    %w[name description].each do |field|
      if params.has_key?(field)
        puts sprintf("%s LIKE '%%%s%%'", field, params[field])
        rs = rs.where(["%s LIKE '%%%s%%'", field, params[field]])
      end
    end

    if params.has_key?('page')
      page = Integer(params['page'])
    end

    if params.has_key?('size')
      size = Integer(params['size'])
      if size > 100
        size = 100
      end
    end
    data = rs.order(created_at: :desc).limit(size).offset(page * 10)
    total = data.except(:offset, :limit, :order).count
    rs_page = PaginationInfo.new data, page, size, total
    rs_page
  end

  # @param multipart_files [Array<UploadedFile>]
  def self.import_coordinates(multipart_files)
    if multipart_files.present?
      begin
        multipart_files.each do |multipart_file|
          logger.info multipart_file
          process_uploaded_file(multipart_file)
        end
      rescue Exception => e
        logger.error e
        raise e
      end
    end
    # contents = multipart_file.read
    # contents.split("\n").each do |line|
    #   logger.info line
    # end
  end

  # @param json_file [ActionDispatch::Http::UploadedFile]
  def self.import(json_file)
    # @type data_hash [Hash]
    data_hash = JSON.parse(json_file.read)
    ActiveRecord::Base.transaction do
      begin
        data_hash['data'].each { |lvl_1_hash|
          attrs = create_unit_attrs(lvl_1_hash, 1)
          parent_lvl_1 = Unit.new attrs
          parent_lvl_1.save!
          lvl_1_hash['level2s'].each { |lvl_2_hash|
            attrs = create_unit_attrs(lvl_2_hash, 2, parent_lvl_1.id)
            parent_lvl_2 = Unit.new attrs
            parent_lvl_2.save!
            # @type arr_lvl_3 [Array]
            arr_lvl_3 = lvl_2_hash['level3s'].map { |lvl_3_hash|
              attrs = create_unit_attrs(lvl_3_hash, 3, parent_lvl_2.id)
              attrs
            }
            unless arr_lvl_3.empty?
              Unit.insert_all!(arr_lvl_3)
            end
          }
        }
      rescue Exception => e
        # logger.error "Error process file #{json_file.original_filename}"
        logger.error e
        raise e
      end
    end
    Unit.where(:level => 1)
  end

  # @param json_file [ActionDispatch::Http::UploadedFile]
  def self.process_uploaded_file(json_file)
    # @type data_hash [Hash]
    data_hash_lvl_1 = JSON.parse(json_file.read)
    ActiveRecord::Base.transaction do
      begin
        unit_lvl_1_id = data_hash_lvl_1["level1_id"]
        create_bbox(data_hash_lvl_1, unit_lvl_1_id)
        create_polygons_coordinates(data_hash_lvl_1, unit_lvl_1_id)
        data_hash_lvl_1['level2s'].each { |data_hash_lvl_2|
          unit_lvl_2_id = data_hash_lvl_2["level2_id"]
          create_bbox(data_hash_lvl_2, unit_lvl_2_id)
          create_polygons_coordinates(data_hash_lvl_2, unit_lvl_2_id)
        }
      rescue Exception => e
        logger.error "Error process file #{json_file.original_filename}"
        raise e
      end
    end
  end

  # @param data_hash [Hash]
  # @param level [Integer]
  # @param parent_id [Integer]
  # @return data_hash [Hash]
  def self.create_unit_attrs(data_hash, level, parent_id = nil)
    attrs = {
      :id => data_hash["level#{level}_id"],
      :name => data_hash['name'],
      :type => data_hash['type'],
      :level => level,
      :parent_id => parent_id,
      :created_at => Time.now,
      :updated_at => Time.now
    }
    attrs
  end

  # @param data_hash [Hash]
  # @param unit_id [Integer]
  def self.create_bbox(data_hash, unit_id)
    unless data_hash.has_key? 'bbox'
      return
    end
    attrs = {
      :min_longitude => data_hash['bbox'][0],
      :min_latitude => data_hash['bbox'][1],
      :max_longitude => data_hash['bbox'][2],
      :max_latitude => data_hash['bbox'][3],
      :unit_id => unit_id
    }
    new_bbox = Bbox.new attrs
    new_bbox.save!
  end

  def self.degree_to_radiant(input)
    input * Math::PI / 180
  end

  EARTH_RADIUS_IN_KM = 6378.137

  # @param [Array<Array<Numeric>>] points
  def self.calculate_polygon_area(points)
    # Initialize area
    area = 0
    # Calculate value of shoelace formula
    unless points.length > 2
      area
    end
    j = points.length - 1
    (0..(points.length - 1)).each { |i|
      area += (2 + Math.sin(degree_to_radiant(points[j]["latitude"])) + Math.sin(degree_to_radiant(points[i]["latitude"]))) * degree_to_radiant(points[j]["longitude"] - points[i]["longitude"])
      j = i; # j is previous vertex to i
    }
    area = area * EARTH_RADIUS_IN_KM * EARTH_RADIUS_IN_KM / 2
    area.abs
  end

  # @param data_hash [Hash]
  # @param unit_id [Integer]
  def self.create_polygons_coordinates(data_hash, unit_id)
    unless data_hash.has_key?('coordinates')
      return
    end
    # if data_hash['type'] == 'Polygon'
    #   data_array = data_hash['coordinates']
    # elsif data_hash['type'] == 'MultiPolygon'
    #   data_array = data_hash['coordinates'][0]
    # else
    #   return
    # end
    polygon_array = data_hash['coordinates']
    polygon_array.each_with_index { |polygon_data, index|
      attrs = {
        :unit_id => unit_id,
      }
      polygon = Polygon.new(attrs)
      polygon.save!
      if data_hash['type'] == 'Polygon'
        coordinate_array = polygon_data
      elsif data_hash['type'] == 'MultiPolygon'
        coordinate_array = polygon_data[0]
      else
        return
      end
      coordinate_attrs_arr = coordinate_array.each_with_index.map { |data_coordinate, point_idx|
        {
          :id => ULID.generate,
          :longitude => data_coordinate[0],
          :latitude => data_coordinate[1],
          :ord => point_idx,
          :polygon_id => polygon.id,
          :created_at => Time.now,
          :updated_at => Time.now
        }
      }
      coordinate_results = Coordinate.insert_all!(coordinate_attrs_arr, returning: %w[ longitude latitude ])
      area = calculate_polygon_area(coordinate_results)
      Polygon.update(id = polygon.id, area: area)
    }
  end

end