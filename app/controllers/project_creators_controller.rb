class ProjectCreatorsController < ApplicationController
  def index
    @creators = ProjectCreator.all
  end

  def new
    @creator = ProjectCreator.new
  end

  def create
    params = creator_params(creator_for_projects)
    @creator = ProjectCreator.create(params)
    render :index
  end

  private

  def creator_params(creator_hash)
    kickstarter_info = included_profile_with(creator_hash)
    {
        name: kickstarter_info['name'],
        slug: kickstarter_info['slug'],
        kickstarter_id: kickstarter_info['id'],
        avatar: kickstarter_info['avatar']['medium'],
        url: kickstarter_info['urls']['web'],
    }
  end

  def included_profile_with(params)
    HTTParty.get(params['urls']['api'])
    params.merge({
      bio: kickstarter_bio,
      created_project_count: kickstarter_project_count,
      kickstarter_created_at: kickstarter_account_created_at,

    })
  end

  def creator_for_projects
    projects = HttParty.get("https://www.kickstarter.com/projects/search.json?term=#{params['name']}&ref=nav_search").to_hash['projects']
    project_from_creator = projects.find {|p| p['creator']['slug'] == params['name']}
    project_from_creator['creator']
  end
end
