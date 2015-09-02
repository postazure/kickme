class Notifier
  def match_projects_and_users
    project_creators = NewProjectFinder.find_creators_with_new_projects
    results_hash = {}

    project_creators.each do |creator|
      users = creator.users
      users.each do |user|
        if results_hash[user]
          results_hash[user] << creator
        else
          results_hash[user] = [ creator ]
        end
      end
    end

    results_hash
  end

  def notify_users
    user_project_hash = match_projects_and_users
    user_project_hash.each do |user, projects|
      UserNotifier.send_new_project_email(user, projects).deliver_now
    end
  end
end