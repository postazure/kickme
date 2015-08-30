require 'rails_helper'

describe ProjectCreatorsController do
  let(:headers) { nil }
  let(:slug)    { 'coolminiornot'}
  let(:last_year) {1.year.ago.in_time_zone('Pacific Time (US & Canada)') }
  let( :user ) { FactoryGirl.create(:user) }

  describe '#index' do
    before do
      FactoryGirl.create(:project_creator, name: 'CoolMiniOrNot')
      FactoryGirl.create(:project_creator, name: 'TMGgames')
    end

    it 'should return all project creators from db' do
      response = get :index
      response_body = JSON.parse(response.body)

      expect(response_body.map {|c| c['name']}).to match_array([ 'CoolMiniOrNot', 'TMGgames' ])
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
      post :search, { 'search_name' => 'CoolMiniOrNot' }
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
    let( :profile_url ) { 'https://api.kickstarter.com/v1/users/1134494596?signature=1440624969.b121fb3fa5339e28ecb0644375a468a6e9990342' }
    let( :profile_data_from_project_search) do
        {
            project_creator: {
                name: "CoolMiniOrNot",
                slug: "coolminiornot",
                kickstarter_id: 12345678,
                avatar: "https://avatar.com/coolminiornot",
                url_web: "https://web.com/coolminiornot",
                url_api: profile_url
            }
        }
    end

    before do
      stub_request( :get, profile_url ).to_return( body: fixture('kickstarter/creator_lookup/coolminiornot.json'))
    end

    context 'a user is logged in' do
      let( :auth_token ) { user.token }

      it 'creates a creator with project search information' do
        test_actions = lambda { post :create, profile_data_from_project_search.merge( token: auth_token) }

        expect(test_actions).to change{ProjectCreator.count}.from(0).to(1)

        project_creator = ProjectCreator.find_by_kickstarter_id(12345678)
        expected_attributes =  profile_data_from_project_search[:project_creator]
        ['name', 'slug', 'kickstarter_id', 'avatar', 'url_web', 'url_api'].each do |attr|
          expect(expected_attributes.values).to include(project_creator[attr])
        end
      end

      it 'adds profile information to db creators' do
        post :create, profile_data_from_project_search.merge( token: auth_token)

        project_creator = ProjectCreator.find_by_kickstarter_id(12345678)
        expect(project_creator.bio).not_to be_nil
        expect(project_creator.created_project_count).not_to be_nil
        expect(project_creator.kickstarter_created_at).not_to be_nil
      end
    end

    context 'a user is NOT logged in' do
      it 'should require a user to be logged in' do
        starting_project_creator_count = ProjectCreator.count
        response = post :create, profile_data_from_project_search
        response_body = JSON.parse(response.body)

        expect(ProjectCreator.count).to eq starting_project_creator_count
        expect(response_body.keys).to include( 'auth', 'message')
        expect(response.status).to eq 401
      end
    end
  end
end