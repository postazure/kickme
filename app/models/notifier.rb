class Notifier
  def self.users_watching_project_creators_with_new_projects
    project_creators = NewProjectFinder.find_creators_with_new_projects
    project_creators.flat_map(&:users)
  end
end