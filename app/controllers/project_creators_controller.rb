class ProjectCreatorsController < ApplicationController
  before_action :authenticate_user_token, only: [:create]

  def index
    render json: ProjectCreator.all
  end

  def create
    project_creator = ProjectCreator.create_with(project_creator_params).find_or_create_by(kickstarter_id: project_creator_params[:kickstarter_id])
    render json: project_creator
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
end
