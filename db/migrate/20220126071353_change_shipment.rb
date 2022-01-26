class ChangeShipment < ActiveRecord::Migration[7.0]
  def change
    remove_column :shipments, :id
    add_column :shipments, :id, :bigint, :primary_key => true
    remove_column :shipments, :from
    remove_column :shipments, :to
    remove_column :shipments, :description
    add_column :shipments, :from_lvl_1_code, :string, :null => false
    add_column :shipments, :from_lvl_2_code, :string, :null => false
    add_column :shipments, :from_lvl_3_code, :string, :null => false
    add_column :shipments, :from_detail, :string
    add_column :shipments, :to_lvl_1_code, :string, :null => false
    add_column :shipments, :to_lvl_2_code, :string, :null => false
    add_column :shipments, :to_lvl_3_code, :string, :null => false
    add_column :shipments, :to_detail, :string
    add_column :shipments, :notes, :text
  end
end
