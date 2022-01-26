class ChangeBboxCoordinates < ActiveRecord::Migration[7.0]
  def change
    change_column_default :bboxes, :x1, 0
    change_column_default :bboxes, :y1, 0
    change_column_default :bboxes, :x2, 0
    change_column_default :bboxes, :y2, 0
  end
end
