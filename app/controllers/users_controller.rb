class UsersController < ApplicationController
  before_action :authenticate_user_token

  def follow
    profile_url = params['project_creator']['profile_url']
    creator_hash = client.get_creator_info_from_url(profile_url)
    project = params['project_creator']['project']
    project_creator_params =  creator_hash.merge(project: project)

    creator = find_or_create_project_creator(project_creator_params)
    user.project_creators << creator
    if creator
      render json: { follow: true }
    else
      render json: { follow: false}
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