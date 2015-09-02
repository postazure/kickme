# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActionMailer::Base.smtp_settings = {
    :user_name => ENV['SENDGRID_EMAIL'],
    :password => ENV['SENDGRID_PASSWORD'],
    :domain => ENV['SENDGRID_DOMAIN'],
    :address => 'smtp.sendgrid.net',
    :port => 587,
    :authentication => :plain,
    :enable_starttls_auto => true
}
ActionMailer::Base.delivery_method = :smtp
