class UnitController < ActionController::API
  include ActionDispatch::Http

  def import
    # @type multipart_file [UploadedFile]
    multipart_file = request.params['file']
    contents = multipart_file.read
    # contents.split("\n").each do |line|
    #   logger.info line
    # end
    # @type data_hash [Hash]
    data_hash = JSON.parse(contents)
    logger.info "Name is #{data_hash['name']} and age is #{data_hash['age']}"
    render status: :ok
  end
end