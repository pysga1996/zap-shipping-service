class Unit < ApplicationRecord
  self.table_name = 'unit'
  self.inheritance_column = :_type_disabled
end
