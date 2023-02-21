class ChangeDelivery < ActiveRecord::Migration[7.0]
  def up

    create_table :delivery, force: :cascade, id: :string do |t|
      t.string :partner_code, null: false
      t.string :partner_name
      t.string :from_lvl_1_code, null: false
      t.string :from_lvl_2_code, null: false
      t.string :from_lvl_3_code, null: false
      t.string :from_detail
      t.string :to_lvl_1_code, null: false
      t.string :to_lvl_2_code, null: false
      t.string :to_lvl_3_code, null: false
      t.string :to_detail
      t.decimal :distance, default: 0
      t.decimal :fee, default: 0
      t.decimal :discount, default: 0
      t.decimal :final_fee, default: 0
      t.text :notes
      t.integer :status, null: false
      t.timestamps
    end

    create_table :delivery_detail, force: :cascade, id: :string do |t|
      t.string :product_id, null: false
      t.string :product_name
      t.decimal :weight_amount, null: false, default: 0
      t.decimal :weight_unit, null: false
      t.string :delivery_id, null: false
      t.timestamps
      t.foreign_key :delivery, column: :delivery_id, primary_key: :id
      t.index :delivery_id
    end

    create_table :partner, force: :cascade, id: :string, primary_key: :code do |t|
      t.string :name, null: false
      t.integer :status, null: false
      t.timestamps
    end

    create_table :partner_policy, force: :cascade, id: :string do |t|
      t.decimal :min_distance, default: 0
      t.decimal :max_distance, default: 0
      t.decimal :fee, default: 0
      t.string :partner_code, null: false
      t.integer :status, null: false
      t.timestamps
      t.foreign_key :partner, column: :partner_code, primary_key: :code
      t.index :partner_code
    end

    create_table :unit, force: :cascade, id: :string, primary_key: :code do |t|
      t.string :name, null: false
      t.string :description
      t.integer :level, null: false
      t.string :parent_code
      t.foreign_key :unit, column: :parent_code, primary_key: :code
      t.index :parent_code
      t.timestamps
    end

    create_table :polygon, force: :cascade, id: :string do |t|
      t.decimal :area, default: 0
      t.string :unit_code, null: false
      t.foreign_key :unit, column: :unit_code, primary_key: :code
      t.index :unit_code
      t.timestamps
    end

    create_table :bbox, force: :cascade, id: :string do |t|
      t.decimal :x1, default: 0
      t.decimal :y1, default: 0
      t.decimal :x2, default: 0
      t.decimal :y2, default: 0
      t.string :polygon_id, null: false
      t.foreign_key :unit, column: :polygon_id, primary_key: :id
      t.index :polygon_id
      t.timestamps
    end

    create_table :coordinate, force: :cascade, id: :string do |t|
      t.decimal :x
      t.decimal :y
      t.string :polygon_id, null: false
      t.foreign_key :polygon, column: :polygon_id, primary_key: :id
      t.index :polygon_id
      t.timestamps
    end

    create_table :user, force: :cascade, id: :string, primary_key: :username do |t|
      t.string :email
      t.integer :status
      t.integer :type
      t.timestamps
    end

  end

  def down

    drop_table :delivery_detail
    drop_table :delivery
    drop_table :partner_policy
    drop_table :partner
    drop_table :coordinate
    drop_table :bbox
    drop_table :polygon
    drop_table :unit
    drop_table :user
  end
end
