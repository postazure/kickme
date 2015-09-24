class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def authenticate_user_token
    render json: { message: 'Auth failed.' }, status: 401 unless User.find_by_token(params[:token])
  end

  def client
    @client ||= KickstarterApiClient.new
  end

  def find_or_create_project_creator(project_creator_params)
    ProjectCreator
        .create_with(project_creator_params)
        .find_or_create_by(
            kickstarter_id: project_creator_params[:kickstarter_id]
        )
  end
end
