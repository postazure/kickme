class NewProjectFinder
  def self.find_creators_with_new_projects
    creators = ProjectCreator.all
    creators.map do |db_pc|
      finder = new(db_pc)
      if creator_has_new_projects(finder.new_project_count)
        match_creators_with_new_projects(db_pc, finder, finder.new_project_count)
      end

    end.compact
  end

  private
  def self.match_creators_with_new_projects(db_pc, finder, num_of_new_projects)
    new_project_hashes = finder.get_newest_projects_with_creator(num_of_new_projects)
    new_projects = new_project_hashes.map { |hash| hash[:project] }
    {
        project_creator: db_pc,
        new_projects: new_projects
    }
  end

  def self.creator_has_new_projects(num_of_new_projects)
    num_of_new_projects > 0
  end

  public
  def initialize(project_creator)
    @project_creator = project_creator
  end

  def new_project_count
    return @new_project_count if @new_project_count

    new_projects_detected = client.get_creator_info_from_url(@project_creator.url_api)[:created_project_count]
    new_projects = new_projects_detected - @project_creator.created_project_count
    if new_projects != 0
      @project_creator.update_attribute(:created_project_count, new_projects_detected)
    end
    @new_project_count = new_projects
  end

  def get_newest_projects_with_creator(n)
    creators_with_projects = client.get_projects_by_creator_name(@project_creator.slug)

    this_creators_projects = creators_with_projects.reject do |p|
      p[:project_creator][:kickstarter_id] != @project_creator.kickstarter_id
    end

    sorted_projects = this_creators_projects.sort_by do |p|
      Date.parse(
          p[:project][:start_at]
      )
    end.reverse
    sorted_projects[0...n]
  end

  private

  def client
    @client ||= KickstarterApiClient.new
  end
end