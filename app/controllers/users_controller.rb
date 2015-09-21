class UsersController < ApplicationController
  before_action :authenticate_user_token

  def follow
    if project_creator
      user.project_creators << project_creator
      render json: { follow: true }
    else
      project_creator_hash = client.get_creator_info_from_url(profile_url)
      new_creator = ProjectCreator.create(project_creator_hash)
      if new_creator
        user.project_creators << new_creator
        render json: { follow: true }
      else
        render json: { follow: false }
      end
    end
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
    @project_creator ||= ProjectCreator.find_by_kickstarter_id(kickstarter_id)
  end

  def kickstarter_id
    params['project_creator']['kickstarter_id']
  end

  def profile_url
    params['project_creator']['profile_url']
  end

  def auth_token
    params[:token] || request.env['user_auth_token']
  end
end