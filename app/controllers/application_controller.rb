class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def authenticate_user_token
    render json: { message: 'Auth failed.' }, status: 401 unless User.find_by_token(params[:token])
  end

  def client
    @client ||= KickstarterApiClient.new
  end
end
