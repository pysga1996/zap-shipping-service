class Bbox < ApplicationRecord
  self.table_name = 'bbox'
  before_create :generate_ulid
end
