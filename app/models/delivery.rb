class Delivery < ApplicationRecord
  self.table_name = 'delivery'
  attr_accessor :id, :partner_code, :from_lvl_3_code, :to_lvl_3_code
  before_create :generate_ulid
end
