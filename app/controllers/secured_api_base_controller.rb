require 'rubygems/stub_specification'

class SecuredApiBaseController < ActionController::API

  attr_reader :current_user
  rescue_from Exception, :with => :handle_exception

  def logged_in?
    @current_user = fetch_current_user
    !!@current_user
  end

  def fetch_current_user
    if auth_present?
      user = User.new
      user_hash = auth[0] # array: 0 - payload, 1 - signature
      user.name = user_hash["preferred_username"]
      user.email = user_hash["email"]
      user
    end
  end

  def authenticate
    render({ json: { error: "Unauthorized" }, status: 401 }) unless logged_in?
  end

  private

  def token
    request.env["HTTP_AUTHORIZATION"].scan(/Bearer (.*)$/).flatten.last
  end

  def auth
    Auth::Jwt.call(token)
  end

  def auth_present?
    !!request.env.fetch("HTTP_AUTHORIZATION", "").scan(/Bearer/).flatten.first
  end

  def handle_exception(e)
    if e.class <= JWT::EncodeError #
      render json: { error: e.message }, status: 401
    elsif e.class <= JWT::DecodeError #
      render json: { error: e.message }, status: 401
    elsif e.class <= Exception #
      render json: { error: e.message }, status: 500
    end
  end
end
