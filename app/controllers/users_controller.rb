class UsersController < ApplicationController
  before_action :authenticate_user_token

  def follow
    user.project_creators << project_creator
    render json: { follow: true }
  end

  def unfollow
    user.project_creators.delete(project_creator)
    render json: { unfollow: true}
  end

  def project_creators
    render json: user.project_creators
  end

  private

  def user
    @user ||= User.find_by_token(auth_token)
  end

  def project_creator
    @project_creator ||= ProjectCreator.find_by_kickstarter_id(params['project_creator']['kickstarter_id'])
  end

  def auth_token
    params[:token] || request.env['user_auth_token']
  end
end