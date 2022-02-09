require 'action_controller'
require 'logger'

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
      page = params['page']
    end

    if params.has_key?('size')
      size = params['size']
      if size > 100
        size = 100
      end
    end
    render json: rs.order(created_at: :desc).limit(size).offset(page * 10)
  end

  # @param multipart_files [Array<UploadedFile>]
  def self.import(multipart_files)
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
  def self.import_lvl_3(json_file)
    # @type data_hash [Hash]
    data_hash = JSON.parse(json_file.read)
    existed_lvl_3_unit_count = Unit.where(:level => 3).count
    if existed_lvl_3_unit_count == 0
      ActiveRecord::Base.transaction do
        begin
          data_hash['data'].each { |lvl_1_hash|
            parent_lvl_1_code = lvl_1_hash['level1_id']
            parent_lvl_1 = Unit.find_by(:code => parent_lvl_1_code)
            if parent_lvl_1 == nil
              attrs = {
                :code => lvl_1_hash['level1_id'],
                :name => lvl_1_hash['name'],
                :level => 2
              }
              parent_lvl_1 = Unit.new attrs
              parent_lvl_1.save!
            end
            lvl_1_hash['level2s'].each { |lvl_2_hash|
              parent_lvl_2_code = lvl_2_hash['level2_id']
              parent_lvl_2 = Unit.find_by(:code => parent_lvl_2_code)
              if parent_lvl_2 == nil
                attrs = {
                  :code => lvl_2_hash['level2_id'],
                  :name => lvl_2_hash['name'],
                  :level => 2,
                  :parent_id => parent_lvl_1.id
                }
                parent_lvl_2 = Unit.new attrs
                parent_lvl_2.save!
              end
              # @type arr_lvl_3 [Array]
              arr_lvl_3 = lvl_2_hash['level3s'].map { |lvl_3_hash|
                code = lvl_3_hash['level3_id']
                name = lvl_3_hash['name']
                parent_id = parent_lvl_2.id
                lvl_3_unit = {
                  :code => code,
                  :name => name,
                  :level => 3,
                  :parent_id => parent_id,
                  :created_at => Time.now,
                  :updated_at => Time.now
                }
                lvl_3_unit
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
    end
    Unit.where(:level => 1)
  end

  # @param json_file [ActionDispatch::Http::UploadedFile]
  def self.process_uploaded_file(json_file)
    # @type data_hash [Hash]
    data_hash = JSON.parse(json_file.read)
    ActiveRecord::Base.transaction do
      begin
        unit_lvl_1_id = create_unit(data_hash, 1)
        create_bbox(data_hash, unit_lvl_1_id)
        create_polygons_coordinates(data_hash, unit_lvl_1_id)
        data_hash['level2s'].each { |data_hash_lvl_2|
          unit_lvl_2_id = create_unit(data_hash_lvl_2, 2, unit_lvl_1_id)
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
  # @return [Integer]
  def self.create_unit(data_hash, level, parent_id = nil)
    attrs = {
      :code => data_hash["level#{level}_id"],
      :name => data_hash['name'],
      :level => level,
      :parent_id => parent_id
    }
    new_unit = Unit.new attrs
    new_unit.save!
    new_unit.id
  end

  # @param data_hash [Hash]
  # @param unit_id [Integer]
  def self.create_bbox(data_hash, unit_id)
    unless data_hash.has_key? 'bbox'
      return
    end
    attrs = {
      :x1 => data_hash['bbox'][0],
      :y1 => data_hash['bbox'][1],
      :x2 => data_hash['bbox'][2],
      :y2 => data_hash['bbox'][3],
      :unit_id => unit_id
    }
    new_bbox = Bbox.new attrs
    new_bbox.save!
  end

  # @param data_hash [Hash]
  # @param unit_id [Integer]
  def self.create_polygons_coordinates(data_hash, unit_id)
    unless data_hash.has_key?('coordinates')
      return
    end
    unless data_hash['coordinate'].instance_of?(Array) && data_hash['coordinate'].length > 0
      return
    end
    if data_hash['coordinates'][0].instance_of?(Array) && data_hash['coordinates'][0].length > 0
      if data_hash['coordinates'][0][0].instance_of?(Array)
        data_array = data_hash['coordinates'][0]
      else
        data_array = data_hash['coordinates']
      end
    else
      return
    end

    polygon_attrs_arr = data_array.map { ||
      {
        :unit_id => unit_id,
        :created_at => Time.now,
        :updated_at => Time.now
      }
    }
    # @type polygon_result [ActiveRecord::Result]
    polygon_results = Polygon.insert_all!(polygon_attrs_arr)
    # @type polygon_result [Array]
    polygon_results.rows.each_with_index do |polygon_result, index|
      coordinate_attrs_arr = data_array[index].map { |data_coordinate|
        {
          :x => data_coordinate[0],
          :y => data_coordinate[1],
          :polygon_id => polygon_result[0],
          :created_at => Time.now,
          :updated_at => Time.now
        }
      }
      Coordinate.insert_all!(coordinate_attrs_arr)
    end
  end

end