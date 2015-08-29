require 'rails_helper'

describe KickstarterApiClient do
  subject { KickstarterApiClient.new }
  let( :project_search_response ) { fixture('kickstarter/project_search/coolminiornot.json') }
  let( :coolmini_profile_url ) { 'https://api.kickstarter.com/v1/users/1134494596?signature=1440624969.b121fb3fa5339e28ecb0644375a468a6e9990342' }
  before do
    stub_request(
        :get, KickstarterApiClient::PROJECT_SEARCH_URL + 'coolminiornot'
    ).to_return( body: project_search_response )
  end
  
  describe '#search_project_creators_by_name' do
    it 'should returns a collection of project creators that matches the query' do
      creators = subject.search_project_creators_by_name('coolminiornot')

      expect(creators).to match_array(
          [
              {
                  name: 'CoolMiniOrNot',
                  profile_url: coolmini_profile_url,
                  profile_avatar: 'https://ksr-ugc.imgix.net/avatars/2326978/cmonlogo250.original.jpg?v=1393237255&w=160&h=160&fit=crop&auto=format&q=92&s=2c5c6b48023bb7a10fc81381eb776dc0'
              },
              {
                  name: 'Michael Mindes',
                  profile_url: 'https://api.kickstarter.com/v1/users/121620721?signature=1440625531.db17631ecab6ee8fde821616f3c7cb0c1c42b85f',
                  profile_avatar: 'https://ksr-ugc.imgix.net/avatars/315828/TMG_Logo_-_RGB_Final.original.png?v=1421102840&w=160&h=160&fit=crop&auto=format&q=92&s=1620667cc4109aa0d0b2cf49127a02ad'
              }
          ]
      )
    end
  end

  describe '#get_creator_info_from_url' do
    let( :profile_search_response ) { fixture('kickstarter/creator_lookup/coolminiornot.json') }
    let( :ks_created_date ) { Date.strptime("1332874154",'%s').to_s }

    before do
      stub_request(
          :get, coolmini_profile_url
      ).to_return( body: profile_search_response )
    end

    it 'should get additional information from creator profile pages' do

      creator = subject.get_creator_info_from_url(coolmini_profile_url)

      expect(creator).to eq(
        {
           bio: 'CoolMiniOrNot is both a studio and publisher of great tabletop games like Zombicide, Dark Age, Wrath of Kings, Rivet Wars, Kaosball, Dogs of War, Arcadia Quest, Xenoshyft and more! We work closely with game creators and indie studios to realize their vision, with a revenue sharing philosophy that is unprecedented in the industry.',
           created_project_count: 18,
           kickstarter_created_at: ks_created_date
        }
      )
    end
  end
end