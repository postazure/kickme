namespace :users do
  desc 'Send emails to notify users of new projects.'
  task notify: :environment do
    logger = Rails.logger
    logger.warn("#{ '*'*100 }\nStarting Notification Task")
    Notifier.new.notify_users
    logger.warn("Ending Notification Task \n#{ '*'*100 }")
  end
end
