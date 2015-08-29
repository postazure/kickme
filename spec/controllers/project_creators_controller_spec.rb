require 'rails_helper'

describe ProjectCreatorsController do
  let(:headers) { nil }
  let(:slug)    { 'coolminiornot'}
  let(:last_year) {1.year.ago.in_time_zone('Pacific Time (US & Canada)') }

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

  describe '#create' do
    let(:profile_data_from_project_search) do
        {
            project_creator: {
                name: "CoolMiniOrNot",
                slug: "coolminiornot",
                kickstarter_id: 12345678,
                avatar: "https://avatar.com/coolminiornot",
                url_web: "https://web.com/coolminiornot",
                url_api: "https://api.com/coolminiornot"
            }
        }
    end

    it 'creates a creator with project search information' do
      test_actions = lambda { post :create, profile_data_from_project_search, headers }

      expect(test_actions).to change{ProjectCreator.count}.from(0).to(1)

      project_creator = ProjectCreator.find_by_kickstarter_id(12345678)
      expected_attributes =  profile_data_from_project_search[:project_creator]
      ['name', 'slug', 'kickstarter_id', 'avatar', 'url_web', 'url_api'].each do |attr|
        expect(expected_attributes.values).to include(project_creator[attr])
      end
    end

    it 'adds profile information to db creators' do
      # API call to get profile page
      post :create, profile_data_from_project_search, headers

      project_creator = ProjectCreator.find_by_kickstarter_id(12345678)
      expected_attributes =  profile_data_from_project_search[:project_creator]
      ['bio', 'created_project_count', 'kickstarter_created_at'].each do |attr|
        expect(expected_attributes.values).to include(project_creator[attr])
      end
    end
  end
end