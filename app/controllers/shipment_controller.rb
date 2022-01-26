class ShipmentController < ActionController::API
  def index
    attr = {
      :id => "4",
      :code => "lozz",
      :from => "HN",
      :to => "HCM"
    }
    s1 = Shipment.new attr
    render json: s1
  end

  def go
    values = ActiveRecord::Base.connection.exec_query('select tablename from system.tables')
  end
end
