FactoryGirl.define do
  factory :project_creator do
    sequence :name
    kickstarter_id {rand(1000..9999)}
    avatar 'http://lorempixel.com/160/160/food/'
    bio 'This is a really good project creator, and they did great things, so back their projects.'
    created_project_count {rand(3..15)}
    kickstarter_created_at {1.year.ago.in_time_zone('Pacific Time (US & Canada)')}
    url_api 'https://need-a-api-url-for-tests.com'
  end

  after(:create) do |project_creator|
    project_creator.slug = project_creator.name.downcase
    project_creator.url_web = "https://www.kickstarter.com/profile/#{project_creator.slug}"
    project_creator.url_api = "https://api.kickstarter.com/v1/users/#{project_creator.kickstarter_id}?signature=1440596030.895c964b7ab965d781eeee1b61425bc6f933747a"
  end
end