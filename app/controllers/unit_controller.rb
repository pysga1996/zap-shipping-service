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
  def create_polygons_coordinates(data_hash, unit_id)
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
        :created_at => Time.new,
        :updated_at => Time.new
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
          :created_at => Time.new,
          :updated_at => Time.new
        }
      }
      Coordinate.insert_all!(coordinate_attrs_arr)
    end
  end

end