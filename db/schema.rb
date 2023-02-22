# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_03_31_072855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bbox", id: :string, force: :cascade do |t|
    t.decimal "min_longitude", default: "0.0", null: false
    t.decimal "min_latitude", default: "0.0", null: false
    t.decimal "max_longitude", default: "0.0", null: false
    t.decimal "max_latitude", default: "0.0", null: false
    t.string "unit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unit_id"], name: "index_bbox_on_unit_id"
  end

  create_table "coordinate", id: :string, force: :cascade do |t|
    t.decimal "longitude", default: "0.0", null: false
    t.decimal "latitude", default: "0.0", null: false
    t.decimal "ord"
    t.string "polygon_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["polygon_id"], name: "index_coordinate_on_polygon_id"
  end

  create_table "delivery", id: :string, force: :cascade do |t|
    t.string "partner_code", null: false
    t.string "partner_name"
    t.string "from_lvl_1_code", null: false
    t.string "from_lvl_2_code", null: false
    t.string "from_lvl_3_code", null: false
    t.string "from_detail"
    t.string "to_lvl_1_code", null: false
    t.string "to_lvl_2_code", null: false
    t.string "to_lvl_3_code", null: false
    t.string "to_detail"
    t.decimal "distance", default: "0.0"
    t.decimal "fee", default: "0.0"
    t.decimal "discount", default: "0.0"
    t.decimal "final_fee", default: "0.0"
    t.text "notes"
    t.integer "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "delivery_detail", id: :string, force: :cascade do |t|
    t.string "product_id", null: false
    t.string "product_name"
    t.decimal "weight_amount", default: "0.0", null: false
    t.decimal "weight_unit", null: false
    t.string "delivery_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["delivery_id"], name: "index_delivery_detail_on_delivery_id"
  end

  create_table "fee_config", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "type"
    t.decimal "value"
    t.decimal "upper_bound"
    t.decimal "lower_bound"
    t.string "bound_unit"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partner", primary_key: "code", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.integer "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partner_policy", id: :string, force: :cascade do |t|
    t.decimal "min_distance", default: "0.0"
    t.decimal "max_distance", default: "0.0"
    t.decimal "fee", default: "0.0"
    t.string "partner_code", null: false
    t.integer "status", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_code"], name: "index_partner_policy_on_partner_code"
  end

  create_table "polygon", id: :string, force: :cascade do |t|
    t.decimal "area", default: "0.0"
    t.string "unit_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unit_id"], name: "index_polygon_on_unit_id"
  end

  create_table "unit", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "type", null: false
    t.string "description"
    t.integer "level", null: false
    t.decimal "area"
    t.string "parent_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["parent_id"], name: "index_unit_on_parent_id"
  end

  create_table "user", primary_key: "username", id: :string, force: :cascade do |t|
    t.string "email"
    t.integer "status"
    t.integer "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bbox", "unit"
  add_foreign_key "coordinate", "polygon"
  add_foreign_key "delivery_detail", "delivery"
  add_foreign_key "partner_policy", "partner", column: "partner_code", primary_key: "code"
  add_foreign_key "polygon", "unit"
  add_foreign_key "unit", "unit", column: "parent_id"
end
