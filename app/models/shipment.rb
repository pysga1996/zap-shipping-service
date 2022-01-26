class Shipment < ApplicationRecord

  attr_accessor :id, :code, :from, :to

  def initialize (id, code, from, to)
    @id = id
    @code = code
    @from = from
    @to = to
  end
  @id
  @code
  @from
  @to

end
