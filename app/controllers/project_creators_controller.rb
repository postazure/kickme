class ProjectCreatorsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    @creators = ProjectCreator.all
  end

  def new
    @creator = ProjectCreator.new
  end

  def create
    ProjectCreator.create(project_creator_params)
    render :index
  end

  def search
    results = KickstarterApiClient.new
                  .search_project_creators_by_name(params['search_name'])
    render json: results
  end

  private

  def project_creator_params
    params.require(:project_creator).permit(:slug)
  end
end
