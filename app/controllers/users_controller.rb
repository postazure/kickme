class UsersController < ApplicationController
  before_action :authenticate_user_token

  def follow
    user.project_creators << project_creator
    render json: { follow: true }
  end

  private

  def user
    @user ||= User.find_by_token(params[:token])
  end

  def project_creator
    @project_creator ||= ProjectCreator.find_by_kickstarter_id(params['project_creator']['kickstarter_id'])
  end
end