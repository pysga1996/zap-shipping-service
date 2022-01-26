class CreateShipments < ActiveRecord::Migration[7.0]
  def change
    create_table :shipments, {:id => false} do |t|
      t.string :id
      t.string :code
      t.string :from
      t.string :to

      t.timestamps
    end
  end
end
