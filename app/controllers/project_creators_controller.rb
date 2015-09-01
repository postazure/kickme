class ProjectCreatorsController < ApplicationController
  before_action :authenticate_user_token, only: [:create]

  def index
    render json: ProjectCreator.all
  end

  def create
    ProjectCreator.create!(project_creator_params)
    render :index
  end

  def search
    results = client.search_project_creators_by_name(params['search_name'])
    render json: results
  end

  private

  def project_creator_params
    profile_url = params['project_creator']['url_api']
    client.get_creator_info_from_url(profile_url)
  end

  def client
    @client ||= KickstarterApiClient.new
  end
end
