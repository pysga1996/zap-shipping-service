class ChangeCoordinate < ActiveRecord::Migration[7.0]
  def change
    add_reference :coordinates, :polygon, foreign_key: true
  end
end
