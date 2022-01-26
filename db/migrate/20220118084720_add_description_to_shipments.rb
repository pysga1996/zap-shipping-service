class AddDescriptionToShipments < ActiveRecord::Migration[7.0]
  def change
    add_column :shipments, :description, :string
  end
end
