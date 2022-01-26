class CreateBboxes < ActiveRecord::Migration[7.0]
  def change
    create_table :bboxes, {:id => false} do |t|
      t.primary_key :id
      t.decimal :x1
      t.decimal :y1
      t.decimal :x2
      t.decimal :y2
      t.timestamps
    end
  end
end
