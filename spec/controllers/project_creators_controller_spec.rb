require 'rails_helper'

describe ProjectCreatorsController do
  let(:headers) { nil }
  let(:slug)    { 'coolminiornot'}

  describe '#index' do
    let!(:coolminiornot) { FactoryGirl.create(:project_creator, name: 'CoolMiniOrNot')}
    let!(:tmg)           { FactoryGirl.create(:project_creator, name: 'TMGgames')}

    it 'should return all project creators from db' do
      expect(subject.index).to match_array(ProjectCreator.all)
    end
  end

  describe '#search' do
    before do
      expect_any_instance_of(KickstarterApiClient)
          .to receive(:search_project_creators_by_name).with('CoolMiniOrNot') {
                [
                    {
                        name: 'CoolMiniOrNot',
                        profile_url: 'https://profile.com/coolminiornot',
                        profile_avatar: 'https://avatar.com/coolminiornot'
                    },
                    {
                        name: 'Michael Mindes',
                        profile_url: 'https://profile.com/michaelmindes',
                        profile_avatar: 'https://avatar.com/michaelmindes'
                    },
                ]
              }
    end

    it 'should return a collection of creator names and api endpoints' do
      post :search, { 'search_name' => 'CoolMiniOrNot' }, headers
      results = JSON.parse(response.body)
      expect(results).to match_array(
        [
            {
                "name" => 'CoolMiniOrNot',
                "profile_url" => 'https://profile.com/coolminiornot',
                "profile_avatar" => 'https://avatar.com/coolminiornot'
            },
            {
                "name" => 'Michael Mindes',
                "profile_url" => 'https://profile.com/michaelmindes',
                "profile_avatar" => 'https://avatar.com/michaelmindes'

            }
        ]
      )
    end
  end

  xdescribe '#create' do
    let(:form_data) { {'project_creator' => {'slug' => slug}} }
    let(:last_year) {1.year.ago.in_time_zone('Pacific Time (US & Canada)') }

    it 'should add project creators to db' do
      test_actions = lambda { post :create, form_data, headers }

      expect(test_actions).to change{ProjectCreator.count}.from(0).to(1)
      expect(ProjectCreator.first.slug).to eq slug
    end

    it 'should save fields' do
      kickstarter_id = 2423123

      project = {
          name: 'CoolMiniOrNot',
          slug: slug,
          kickstarter_id: kickstarter_id,
          avatar: 'avatar',
          url_web: 'url_web',
          url_api: "https://api.kickstarter.com/v1/users/#{kickstarter_id}?signature=1440596030.895c964b7ab965d781eeee1b61425bc6f933747a",
          bio: 'About the company, stuff stuff stuff.',
          created_project_count: 1,
          kickstarter_created_at: last_year
      }.with_indifferent_access

      post :create, form_data, headers
      expect(ProjectCreator.count).to eq 1

      creator = ProjectCreator.first
      fields = %w[ name slug kickstarter_id avatar url_web url_api bio created_project_count kickstarter_created_at ]
      fields.each do |attribute|
        expect(creator.send(attribute)).to eq project[attribute]
      end
    end
  end
end