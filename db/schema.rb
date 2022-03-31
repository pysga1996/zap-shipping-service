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
  enable_extension "adminpack"
  enable_extension "plpgsql"

  create_table "bboxes", force: :cascade do |t|
    t.decimal "x1", default: "0.0"
    t.decimal "y1", default: "0.0"
    t.decimal "x2", default: "0.0"
    t.decimal "y2", default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "unit_id"
    t.index ["unit_id"], name: "index_bboxes_on_unit_id"
  end

  create_table "coordinates", force: :cascade do |t|
    t.decimal "x"
    t.decimal "y"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "polygon_id"
    t.index ["polygon_id"], name: "index_coordinates_on_polygon_id"
  end

  create_table "polygons", force: :cascade do |t|
    t.bigint "unit_id"
    t.decimal "area", default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["unit_id"], name: "index_polygons_on_unit_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "from_lvl_1_code", null: false
    t.string "from_lvl_2_code", null: false
    t.string "from_lvl_3_code", null: false
    t.string "from_detail"
    t.string "to_lvl_1_code", null: false
    t.string "to_lvl_2_code", null: false
    t.string "to_lvl_3_code", null: false
    t.string "to_detail"
    t.text "notes"
    t.string "order_code", null: false
    t.decimal "total_cost", default: "0.0", null: false
    t.decimal "price_cost", default: "0.0", null: false
    t.decimal "shipping_cost", default: "0.0", null: false
  end

  create_table "units", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "level", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "parent_id"
    t.index ["code"], name: "index_units_on_code", unique: true
    t.index ["parent_id"], name: "index_units_on_parent_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.integer "status"
    t.integer "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "bboxes", "units"
  add_foreign_key "coordinates", "polygons"
  add_foreign_key "polygons", "units"
  add_foreign_key "units", "units", column: "parent_id"
end
