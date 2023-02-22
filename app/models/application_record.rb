class ApplicationRecord < ActiveRecord::Base
  require 'ulid'
  primary_abstract_class
  protected
  def generate_ulid
    self.id = ULID.generate
  end
end
