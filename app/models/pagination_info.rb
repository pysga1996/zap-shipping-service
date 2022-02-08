class PaginationInfo
  attr_accessor :data, :page, :size, :total_elements, :total_pages

  def initialize(data, page, size, total)
    @data = data
    @page = page
    @size = size
    @total_elements = total
    @total_pages = (total / size).ceil
  end
end
