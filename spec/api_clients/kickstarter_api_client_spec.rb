require 'rails_helper'

describe KickstarterApiClient do
  subject { KickstarterApiClient.new }
  let( :project_search_response ) { fixture('kickstarter/project_search/coolminiornot.json') }
  let( :profile_lookup_response ) { fixture('kickstarter/creator_lookup/coolminiornot.json') }
  let( :profile_url ) { 'https://api.kickstarter.com/v1/users/1134494596?signature=1440624969.b121fb3fa5339e28ecb0644375a468a6e9990342' }

  describe '#search_project_creators_by_name' do
    before do
      stub_request(
          :get, KickstarterApiClient::PROJECT_SEARCH_URL + 'coolminiornot'
      ).to_return( body: project_search_response )

      stub_request(
          :get, profile_url
      ).to_return( body: profile_lookup_response )
    end

    it 'should returns a collection of project creators that matches the query' do
      creators = subject.search_project_creators_by_name('coolminiornot')

      expect(creators).to match_array(
          [
              { name: 'CoolMiniOrNot', profile_url: profile_url },
              { name: 'Michael Mindes', profile_url: 'https://api.kickstarter.com/v1/users/121620721?signature=1440625531.db17631ecab6ee8fde821616f3c7cb0c1c42b85f'}
          ]
      )
    end
  end
end