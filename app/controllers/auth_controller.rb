class AuthController < ApplicationController
  def create
    user = User.find_by_email(params['email'])

    if authenticated_user?(user)
      user.regenerate_token
      token = user.token
      render json: { auth: true, token: token }, status: 200
    else
      render json: { auth: false }, status: 401
    end
  end

  def destroy
    user = User.find_by_token(params['token'])
    user.update( token: nil )

    render json: { auth: true }
  rescue
      render json: { auth: false }, status: 422
  end

  private

  def authenticated_user?(db_user)
    db_user.authenticate(params[:password])
  rescue
    false
  end
end