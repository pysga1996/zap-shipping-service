class ChangeBbox < ActiveRecord::Migration[7.0]
  def change
    add_reference :bboxes, :unit, foreign_key: true
  end
end
