class CreatePolygons < ActiveRecord::Migration[7.0]
  def change
    create_table :polygons do |t|
      t.references :unit, index: true, foreign_key: true
      t.decimal :area, default: 0
      t.timestamps
    end
  end
end
