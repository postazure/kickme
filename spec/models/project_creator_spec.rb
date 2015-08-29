require 'rails_helper'

describe ProjectCreator do
  describe 'relationships' do
    let( :user ) { FactoryGirl.create(:user) }
    let( :project_creator ) { FactoryGirl.create(:project_creator) }

    before do
      using_project_creator_factory
      project_creator
    end

    it 'users can follow many project_creators' do
      test_actions = lambda {
        project_creator.users << user
      }

      expect(test_actions).to change{user.project_creators.count}.from(0).to(1)
    end
  end


  describe '#get_additional_profile_info' do
    let( :profile_url ) { 'https://api.kickstarter.com/v1/users/1134494596?signature=1440596116.4a1058214fbacf8eec787edaeea9a646d1f5a351' }
    before do
      allow_any_instance_of(KickstarterApiClient).to receive(:get_creator_info_from_url).and_return(
          {
              bio: 'Test Bio',
              created_project_count: 4,
              kickstarter_created_at: Date.today
          }
      )
    end

    it 'should get additonal info on before save' do
      creator = ProjectCreator.new(url_web: profile_url)
      creator.save!

      expect(creator.bio).not_to be_nil
      expect(creator.created_project_count).not_to be_nil
      expect(creator.kickstarter_created_at).not_to be_nil
    end
  end
end