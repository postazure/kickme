class Notifier
  def build_user_notification_list
    NewProjectFinder.update_creator_api_signatures
    creators_and_projects = NewProjectFinder.find_creators_with_new_projects

    users_notification_info = []
    creators_and_projects.each do |creator_info|

      add_to_users_info(creator_info, users_notification_info)
    end

    users_notification_info
  end

  def notify_users
    notification_info_list = build_user_notification_list
    notification_info_list.each do |notification|
      UserNotifier.send_new_project_email(notification).deliver_now
    end
  end

  private

  def add_to_users_info(creator_info, users_notification_info)
    project_creator = creator_info[:project_creator]
    projects = creator_info[:new_projects]
    project_creator_users = project_creator.users

    project_creator_users.each do |user|
      user_in_info = users_notification_info.find { |info| info[:user].id == user.id }
      if user_in_info
        user_in_info[:new_projects_by_creators] << {
            creator: project_creator,
            projects: projects
        }
      else
        users_notification_info << {
            user: user,
            new_projects_by_creators: [
                {
                    creator: project_creator,
                    projects: projects
                }
            ]
        }
      end
    end
  end
end