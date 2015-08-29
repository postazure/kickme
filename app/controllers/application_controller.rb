class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def authenticate_user_token
    provided_token = params['token']
    if User.find_by_token(provided_token).nil?
      render json: { auth: false, message: 'You need to log in.' }, status: 401
    end
  end
end
