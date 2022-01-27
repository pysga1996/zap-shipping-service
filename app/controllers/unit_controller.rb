class UnitController < ActionController::API
  include ActionDispatch::Http

  # Postman params need in form of json_files[] for rails to recognize multiple files upload
  def import
    # @type multipart_files [Array<UploadedFile>]
    multipart_files = request.params['json_files']
    if multipart_files.present?
      begin
        multipart_files.each do |multipart_file|
          logger.info multipart_file
          process_uploaded_file(multipart_file)
        end
      rescue Exception => e
        logger.error e
        return render status: :internal_server_error
      end
    end
    # contents = multipart_file.read
    # contents.split("\n").each do |line|
    #   logger.info line
    # end
    render status: :ok
  end

  # @param json_file [UploadedFile]
  def process_uploaded_file(json_file)
    # @type data_hash [Hash]
    data_hash = JSON.parse(json_file.read)
    ActiveRecord::Base.transaction do
      begin
        unit_lvl_1_id = create_unit data_hash, 1
        create_bbox(data_hash, unit_lvl_1_id)
        create_polygons_coordinates(data_hash['coordinates'][0], unit_lvl_1_id)
        data_hash['level2s'].each { |data_hash_lvl_2|
          unit_lvl_2_id = create_unit(data_hash_lvl_2, 2, unit_lvl_1_id)
          create_bbox(data_hash_lvl_2, unit_lvl_2_id)
          create_polygons_coordinates(data_hash_lvl_2['coordinates'][0], unit_lvl_2_id)
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
  def create_unit(data_hash, level, parent_id = nil)
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
  def create_bbox(data_hash, unit_id)
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

  # @param data_array [Array]
  # @param unit_id [Integer]
  def create_polygons_coordinates(data_array, unit_id)
    polygon_arr = Array.new
    # @type data_hash_polygon [Array]
    data_array.each { |data_polygon|
      attrs = {
        :unit_id => unit_id
      }
      new_polygon = Polygon.new attrs
      # new_polygon.save!
      new_polygon.coordinate_list = data_polygon
      polygon_arr.push(new_polygon)
      # polygon_lvl_id = new_polygon.id
      # coordinate_arr = Array.new
      # @type data_coordinate [Array]
      # data_polygon.each { |data_coordinate|
      #   attrs = {
      #     :x => data_coordinate[0],
      #     :y => data_coordinate[1],
      #     :polygon_id => polygon_lvl_id
      #   }
      #   new_coordinate = Coordinate.new attrs
      #   coordinate_arr.push(new_coordinate)
      #   # new_coordinate.save!
      # }
      # Coordinate.insert_all!(coordinate_arr)
    }
    Polygon.insert_all!(polygon_arr)
    # @type polygon [Polygon]
    polygon_arr.each do |polygon|
      coordinate_arr = Array.new
      polygon.coordinate_list.each { |data_coordinate|
        attrs = {
          :x => data_coordinate[0],
          :y => data_coordinate[1],
          :polygon_id => polygon.id
        }
        new_coordinate = Coordinate.new attrs
        coordinate_arr.push(new_coordinate)
      }
      Coordinate.insert_all!(coordinate_arr)
    end
  end

end