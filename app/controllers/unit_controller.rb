class UnitController < ApplicationController
  include UnitService

  def get_lvl_1_units
    @units = UnitService.get_lvl_1_units
    render template: "unit/all", layout: "main"
  end

  def get_lvl_2_units
    parent_id = params['parent-id']
    @units = UnitService.get_lvl_2_units(parent_id)
    render template: "unit/all"
  end

  def get_lvl_3_units
    parent_id = params['parent-id']
    @units = UnitService.get_lvl_3_units(parent_id)
    render "unit/all"
  end

  # @type json_file [ActionDispatch::Http::UploadedFile]
  def import_lvl_3
    json_file = request.params['json_file']
    begin
      @units = UnitService.import_lvl_3(json_file)
      render "unit/all"
    rescue Exception => e
      logger.error e
      redirect_to "/view/error"
    end
  end

end
