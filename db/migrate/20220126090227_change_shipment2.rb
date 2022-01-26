class ChangeShipment2 < ActiveRecord::Migration[7.0]
  def change
    add_column :shipments, :order_code, :string, :index => true, :null => false
    add_column :shipments, :price_cost, :decimal, :null => false, default: 0
    add_column :shipments, :shipping_cost, :decimal, :null => false, default: 0
    add_column :shipments, :total_cost, :decimal, :null => false, default: 0
  end
end
