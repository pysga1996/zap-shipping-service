class Polygon < ApplicationRecord
  self.table_name = 'polygon'
  before_create :generate_ulid
end
