FactoryGirl.define do
  factory :project_creator do
    sequence(:name)  { |n| "FactoryProjectCreator#{n}" }
    kickstarter_id {rand(1000..9999)}
    avatar 'http://lorempixel.com/160/160/food/'
    bio 'This is a really good project creator, and they did great things, so back their projects.'
    created_project_count {rand(3..15)}
    kickstarter_created_at {1.year.ago.in_time_zone('Pacific Time (US & Canada)')}
    sequence(:url_api) {|n| "https://need-a-api-url-for-tests.com/#{n}"}

    after(:build) do |project_creator|
      project_creator.slug = project_creator.name.downcase
      project_creator.url_web = "https://www.kickstarter.com/profile/#{project_creator.slug}"
    end
  end
end