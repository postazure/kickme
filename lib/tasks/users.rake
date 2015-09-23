namespace :users do
  desc 'Send emails to notify users of new projects.'
  task notify: :environment do
    Notifier.new.notify_users
  end
end
