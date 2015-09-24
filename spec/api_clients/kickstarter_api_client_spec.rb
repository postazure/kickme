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
                  kickstarter_id: 1134494596,
                  profile_url: coolmini_profile_url,
                  profile_avatar: 'https://ksr-ugc.imgix.net/avatars/2326978/cmonlogo250.original.jpg?v=1393237255&w=160&h=160&fit=crop&auto=format&q=92&s=2c5c6b48023bb7a10fc81381eb776dc0',
                  project: 'CoolMiniOrNot Base System Featuring Micro Art Studio'
              },
              {
                  name: 'Michael Mindes',
                  kickstarter_id: 121620721,
                  profile_url: 'https://api.kickstarter.com/v1/users/121620721?signature=1440625531.db17631ecab6ee8fde821616f3c7cb0c1c42b85f',
                  profile_avatar: 'https://ksr-ugc.imgix.net/avatars/315828/TMG_Logo_-_RGB_Final.original.png?v=1421102840&w=160&h=160&fit=crop&auto=format&q=92&s=1620667cc4109aa0d0b2cf49127a02ad',
                  project: 'Eminent Domain: MICROCOSM + TMG Promos'
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
           name: 'CoolMiniOrNot',
           slug: 'coolminiornot',
           kickstarter_id: 1134494596,
           avatar: 'https://ksr-ugc.imgix.net/avatars/2326978/cmonlogo250.original.jpg?v=1393237255&w=160&h=160&fit=crop&auto=format&q=92&s=2c5c6b48023bb7a10fc81381eb776dc0',
           url_web: 'https://www.kickstarter.com/profile/coolminiornot',
           url_api: 'https://api.kickstarter.com/v1/users/1134494596?signature=1440596116.4a1058214fbacf8eec787edaeea9a646d1f5a351',
           bio: 'CoolMiniOrNot is both a studio and publisher of great tabletop games like Zombicide, Dark Age, Wrath of Kings, Rivet Wars, Kaosball, Dogs of War, Arcadia Quest, Xenoshyft and more! We work closely with game creators and indie studios to realize their vision, with a revenue sharing philosophy that is unprecedented in the industry.',
           created_project_count: 18,
           kickstarter_created_at: ks_created_date
        }
      )
    end
  end

  describe '#get_projects_by_creator_name' do
    it 'should return a collection of projects' do
      results = subject.get_projects_by_creator_name('coolminiornot')
      expect(results).to include(
         {
             project_creator: {
                 name: 'CoolMiniOrNot',
                 kickstarter_id: 1134494596,
                 profile_url: coolmini_profile_url,
                 profile_avatar: 'https://ksr-ugc.imgix.net/avatars/2326978/cmonlogo250.original.jpg?v=1393237255&w=160&h=160&fit=crop&auto=format&q=92&s=2c5c6b48023bb7a10fc81381eb776dc0'
             },
             project: {
                 name: 'CoolMiniOrNot Base System Featuring Micro Art Studio',
                 blurb: 'Beautiful, affordable terrain bases for all your miniatures!',
                 kickstarter_id: 1231771828,
                 pledged: 88259,
                 currency: 'USD',
                 state: 'successful',
                 end_at: '2014-10-05',
                 start_at: '2014-09-19',
                 image: 'https://ksr-ugc.imgix.net/projects/1238317/photo-original.jpg?v=1407799072&w=266&h=200&fit=crop&auto=format&q=92&s=e476c5d79b9da546b0a19d10a838cf70',
                 url_rewards: 'https://www.kickstarter.com/projects/coolminiornot/coolminiornot-base-system-featuring-micro-art-stud/rewards',
                 url_project: 'https://www.kickstarter.com/projects/coolminiornot/coolminiornot-base-system-featuring-micro-art-stud?ref=discovery'
             }
         }
      )
      expect(results.length).to eq 19
    end
  end
end