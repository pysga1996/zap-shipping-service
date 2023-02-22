class DeliveryDetail < ApplicationRecord
  self.table_name = 'delivery_detail'
  before_create :generate_ulid
end
