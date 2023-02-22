class Coordinate < ApplicationRecord
  self.table_name = 'coordinate'
  before_create :generate_ulid
end
