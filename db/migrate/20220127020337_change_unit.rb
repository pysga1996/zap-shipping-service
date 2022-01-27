class ChangeUnit < ActiveRecord::Migration[7.0]
  def change
    add_column :units, :parent_id, :bigint
    add_foreign_key :units, :units, column: :parent_id
    add_index :units, :parent_id
  end
end
