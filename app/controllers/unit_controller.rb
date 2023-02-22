class UnitController < ApplicationController
  include UnitService

  def get_all_root_units
    @units = UnitService.get_lvl_1_units
    render template: "unit/all", layout: "main"
  end

  def get_unit_detail
    code = params['id']
    @unit_detail = UnitService.get_unit_by_id(code)
    if @unit_detail.level == 1
      @units = UnitService.get_lvl_2_units(code)
    elsif @unit_detail.level == 2
      @units = UnitService.get_lvl_3_units(code)
    else
      @units = []
    end
    render template: "unit/detail", layout: "main"
  end

  # @type json_file [ActionDispatch::Http::UploadedFile]
  def import
    json_file = request.params['json_file']
    begin
      @units = UnitService.import(json_file)
      render "unit/all", layout: "main"
    rescue Exception => e
      logger.error e
      redirect_to "#{$base_path}/view/error", flash: {message: e.message}
    end
  end

end
