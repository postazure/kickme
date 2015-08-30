class ProjectCreatorsController < ApplicationController
  before_action :authenticate_user_token, only: [:create]

  def index
    render json: ProjectCreator.all
  end

  def create
    project_creator = ProjectCreator.new(project_creator_params)
    project_creator.get_additional_profile_info
    project_creator.save

    render :index
  end

  def search
    results = KickstarterApiClient.new
      .search_project_creators_by_name(params['search_name'])
    render json: results
  end

  private

  def project_creator_params
    params.require(:project_creator).permit(
        :name, :slug, :kickstarter_id, :avatar, :url_web, :url_api
    )
  end
end
