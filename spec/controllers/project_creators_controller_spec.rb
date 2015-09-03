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
                  kickstarter_id: 123456,
                  profile_url: 'https://profile.com/coolminiornot',
                  profile_avatar: 'https://avatar.com/coolminiornot'
              },
              {
                  name: 'Michael Mindes',
                  kickstarter_id: 654321,
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
              'name' => 'CoolMiniOrNot',
              'kickstarter_id' => 123456,
              'profile_url' => 'https://profile.com/coolminiornot',
              'profile_avatar' => 'https://avatar.com/coolminiornot'
          },
          {
              'name' => 'Michael Mindes',
              'kickstarter_id' => 654321,
              'profile_url' => 'https://profile.com/michaelmindes',
              'profile_avatar' => 'https://avatar.com/michaelmindes'

          }
        ]
      )
    end
  end

  describe '#create' do
    let( :profile_url ) { 'https://api.kickstarter.com/v1/users/1134494596?signature=1440624969.b121fb3fa5339e28ecb0644375a468a6e9990342' }
    let( :kickstarter_id ) { 1134494596 }
    let( :hash_from_web_client) do
        {
            project_creator: {
                name: 'CoolMiniOrNot',
                kickstarter_id: kickstarter_id,
                profile_avatar: 'https://avatar.com/coolminiornot',
                url_api: profile_url
            }
        }
    end

    before do
      stub_request( :get, profile_url ).to_return( body: fixture('kickstarter/creator_lookup/coolminiornot.json'))
    end

    context 'a user is logged in' do
      let( :auth_token ) { user.token }

      it 'creates a project creator with profile information' do
        expected_attributes = %w[ name slug kickstarter_id avatar url_web url_api bio created_project_count kickstarter_created_at ]
        post :create, hash_from_web_client.merge( token: auth_token)
        project_creator = ProjectCreator.find_by_kickstarter_id(1134494596)

        expected_attributes.each do |attr|
          puts "\nAttribute: #{attr} is missing a value" if project_creator[attr].nil?
          expect(project_creator[attr]).not_to be_nil
        end
      end
    end

    context 'a user is NOT logged in' do
      it 'should require a user to be logged in' do
        starting_project_creator_count = ProjectCreator.count
        response = post :create, hash_from_web_client
        response_body = JSON.parse(response.body)

        expect(ProjectCreator.count).to eq starting_project_creator_count
        expect(response_body.keys).to include( 'message')
        expect(response.status).to eq 401
      end
    end
  end
end