class RegistrationsController < ApplicationController
  def create
    user = User.new( user_params )
    if user.save
      render json: { registered: true, token: user.token }
    else
      render json: { errors: user.errors }, status: 422
    end
  end

  private

  def user_params
    params.require( :user ).permit( :email, :password )
  end
end