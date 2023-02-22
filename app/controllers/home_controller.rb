class HomeController < ActionController::Base
  def index
    @owner = "pysga1996"
  end

  def error
    render template: "home/error", layout: "main"
  end
end
