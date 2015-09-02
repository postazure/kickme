class UserNotifier < ActionMailer::Base
  default :from => 'new_projects@mykickalerts.com'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    mail( to: @user.email,
          subject: "Thanks for signing up, #{@user.email}!")
  end

  def send_new_project_email(user, project_creators)
    @user = user
    @project_creators = project_creators

    project_creators_for_subject = @project_creators.map(&:name).join(' & ')
    mail(
        to: @user.email,
        subject: "#{project_creators_for_subject} Posted A New Project"
    )
  end
end