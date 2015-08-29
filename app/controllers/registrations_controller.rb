class RegistrationsController < ApplicationController
  def create
    user = User.new( user_params )
    if user.save
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require( :user ).permit( :email, :password )
  end
end