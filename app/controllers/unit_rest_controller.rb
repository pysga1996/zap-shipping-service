class UnitRestController < ActionController::API
  include ActionDispatch::Http

  def get_lvl_1_units
    render json: UnitService.get_lvl_1_units
  end

  def get_lvl_2_units
    parent_id = params['parent-id']
    render json: UnitService.get_lvl_2_units(parent_id)
  end

  def get_lvl_3_units
    parent_id = params['parent-id']
    render json: UnitService.get_lvl_3_units(parent_id)
  end

  def get_unit_by_id
    id = params['id']
    render json: UnitService.get_unit_by_id(id)
  end

  def get_units_by_conditions
    render json: UnitService.get_units_by_conditions(params)
  end

  # Postman params need in form of json_files[] for rails to recognize multiple files upload
  def import
    # @type multipart_files [Array<UploadedFile>]
    multipart_files = request.params['json_files']
    begin
      UnitService.import(multipart_files)
      return render status: :ok
    rescue Exception => e
      logger.error e
      return render status: :internal_server_error
    end
  end

end