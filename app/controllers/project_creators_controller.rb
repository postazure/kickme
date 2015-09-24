class ProjectCreatorsController < ApplicationController
  before_action :authenticate_user_token, only: [:create]

  def index
    render json: ProjectCreator.all
  end

  def create
    project_creator = find_or_create_project_creator(project_creator_params)

    render json: project_creator
  end

  def search
    results = client.search_project_creators_by_name(params['search_name'])
    render json: results
  end


  def project_creator_params
    profile_url = params['project_creator']['url_api']
    creator_hash = client.get_creator_info_from_url(profile_url)
    project = params['project_creator']['project']
    creator_hash.merge(project: project)
  end
end
