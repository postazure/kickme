class NewProjectFinder
  def self.find_creators_with_new_projects
    creators = ProjectCreator.all
    creators.map do |pc|
      pc if new(pc).new_project?
    end.compact
  end

  def initialize(project_creator)
    @project_creator = project_creator
  end

  def new_project?
    profile_url = @project_creator.url_api
    profile_hash = client.get_creator_info_from_url(profile_url)
    if profile_hash[:created_project_count] != @project_creator.created_project_count
      @project_creator.update_attribute(:created_project_count, profile_hash[:created_project_count])
    else
      false
    end
  end

  def get_newest_projects_with_creator(n)
    creators_with_projects = client.get_projects_by_creator_name(@project_creator.slug)

    this_creators_projects = creators_with_projects.reject do |p|
      p[:project_creator][:kickstarter_id] != @project_creator.kickstarter_id
    end

    sorted_projects = this_creators_projects.sort_by { |p| Date.parse(p[:project][:start_at]) }.reverse
    sorted_projects[0...n]
  end

  private

  def client
    @client ||= KickstarterApiClient.new
  end
end