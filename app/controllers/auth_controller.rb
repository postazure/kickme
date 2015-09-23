class AuthController < ApplicationController
  skip_before_action :authenticate_user_token, only: [:destroy]
  def create
    user = User.find_by_email(params['email'])

    if authenticated_user?(user)
      user.regenerate_token
      render json: { token: user.reload.token}, status: 200
    else
      render nothing: true, status: 401
    end
  end

  def destroy
    user = User.find_by_token(params['token'])
    user.regenerate_token if user

    render nothing: true, status: 200
  end

  private

  def authenticated_user?(db_user)
    db_user.authenticate(params[:password])
  rescue
    false
  end
end