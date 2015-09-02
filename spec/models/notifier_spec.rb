require 'rails_helper'

describe Notifier do
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
  let( :matched_users_and_projects ) do
    {
        valid_users[0] => [ creator_with_new_project1 ],
        valid_users[1] => [ creator_with_new_project1 ],
        valid_users[2] => [ creator_with_new_project1, creator_with_new_project2 ],
        valid_users[3] => [ creator_with_new_project1, creator_with_new_project2 ]
    }
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
    valid_users[2].project_creators << creator_with_new_project2 << creator_with_new_project1
    valid_users[3].project_creators << creator_with_new_project2 << creator_with_new_project1

    invalid_users.first.project_creators << creator_without_new_project
    invalid_users.last.project_creators << creator_without_new_project
  end

  describe '#match_projects_and_users' do
    it 'should return a user with the project creators that have added projects' do
      results = Notifier.new.match_projects_and_users
      expect(results).to eq(matched_users_and_projects)
    end
  end

  describe '#notify_users' do
    let( :notifier ) { Notifier.new }

    before do
      allow(notifier).to receive(:match_projects_and_users).and_return(matched_users_and_projects)
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    after do
      UserNotifier.deliveries.clear
    end

    it 'should request an email for each user to be notified' do
      notifier.notify_users
      expect(UserNotifier.deliveries.count).to eq 4
    end
  end
end
