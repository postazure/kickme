class UserNotifier < ActionMailer::Base
  default :from => 'new_projects@mykickalerts.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( to: @user.email,
          subject: "Thanks for signing up, #{@user.email}!")
  end

  def send_new_project_email(notification)
    @user = notification[:user]
    @new_projects_by_creators = notification[:new_projects_by_creators]

    mail(
        to: @user.email,
        subject: "#{@new_projects_by_creators.first[:creator].name} Posted A New Project"
    )
  end
end