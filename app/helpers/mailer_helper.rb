module MailerHelper
  def new_project_count(new_projects_by_creators)
    sum = 0
    new_projects_by_creators.each do |h|
      sum += h[:projects].count
    end
    sum
  end
end
