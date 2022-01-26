class CreateUnits < ActiveRecord::Migration[7.0]
  def change
    create_table :units do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false
      t.string :description
      t.integer :level, null: false
      t.timestamps
    end
  end
end
