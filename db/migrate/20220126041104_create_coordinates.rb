class CreateCoordinates < ActiveRecord::Migration[7.0]
  def change
    create_table :coordinates do |t|
      t.decimal :x
      t.decimal :y
      t.bigint :polygon_id
      t.timestamps
      t.references
    end
  end
end
