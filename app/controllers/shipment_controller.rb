class ShipmentController < ActionController::API
  def index
    s1 = Shipment.new 4, "lozz" , "HN", "HCM"
    render json: s1
  end
end
