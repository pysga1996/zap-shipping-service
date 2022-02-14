class UnitController < ApplicationController
  include UnitService

  def get_all_root_units
    @units = UnitService.get_lvl_1_units
    render template: "unit/all", layout: "main"
  end

  def get_unit_detail
    id = params['id']
    @unit_detail = UnitService.get_unit_by_id(id)
    if @unit_detail.level == 1
      @units = UnitService.get_lvl_2_units(id)
    elsif @unit_detail.level == 2
      @units = UnitService.get_lvl_3_units(id)
    else
      @units = []
    end
    render template: "unit/detail", layout: "main"
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
