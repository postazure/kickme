require 'rails_helper'

describe Notifier do
  # describe '.alert_users_about_new_projects' do
  #   it 'should request emails to be sent' do
  #     raise 'Write this test'
  #   end
  # end

  describe '.users_watching_project_creators_with_new_projects' do
    let( :creator_with_new_project1 ) { FactoryGirl.create(:project_creator, created_project_count: 1, url_api: 'creator_with_new_project') }
    let( :creator_with_new_project2 ) { FactoryGirl.create(:project_creator, created_project_count: 1, url_api: 'creator_with_new_project') }
    let( :creator_without_new_project ) { FactoryGirl.create(:project_creator, created_project_count: 1, url_api: 'creator_without_new_project') }

    let( :valid_users ) do
      [
          FactoryGirl.create(:user),
          FactoryGirl.create(:user),
          FactoryGirl.create(:user),
          FactoryGirl.create(:user)
      ]
    end

    let( :invalid_users ) do
      [
          FactoryGirl.create(:user),
          FactoryGirl.create(:user)
      ]
    end

    before do
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with('creator_with_new_project')
          .and_return({ created_project_count: 2 })
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with('creator_without_new_project')
          .and_return({ created_project_count: 1 })

      valid_users[0].project_creators << creator_with_new_project1
      valid_users[1].project_creators << creator_with_new_project1
      valid_users[2].project_creators << creator_with_new_project2
      valid_users[3].project_creators << creator_with_new_project2

      invalid_users.first.project_creators << creator_without_new_project
      invalid_users.last.project_creators << creator_without_new_project
    end

    it 'should get a list of users that watch those creators' do
      users_to_notify = Notifier.users_watching_project_creators_with_new_projects
      expect(users_to_notify).to match_array(valid_users)
    end
  end
end
