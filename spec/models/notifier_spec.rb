require 'rails_helper'

describe Notifier do
  describe '#build_user_notification_list' do
    let!( :user1 ) { FactoryGirl.create(:user) }
    let!( :creator1 ) { FactoryGirl.create(:project_creator) }
    let( :project_hash ) do
      {
          name: 'creator1 project',
          blurb: 'foo',
          kickstarter_id: 12,
          pledged: 12,
          currency: 'USD',
          state: 'bar',
          end_at: '2014-01-31',
          start_at: '2014-01-01',
          image: 'image',
          url_rewards: 'rewards',
          url_project: 'project'
      }
    end

    before do
      user1.project_creators << creator1
    end

    context 'when there is only one user affected by one project creator' do
      before do
        allow(NewProjectFinder).to receive(:find_creators_with_new_projects)
                                       .and_return([
                                                       {
                                                           project_creator: creator1,
                                                           new_projects: [project_hash]
                                                       }
                                                   ])
      end

      it 'should return a collection of users with all creators and their projects' do
        results = Notifier.new.build_user_notification_list

        expect(results).to include(
                               {
                                   user: user1,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               }
                           )
      end
    end

    context 'when there is only one user affected by two project creators' do
      let!( :creator2 ) { FactoryGirl.create(:project_creator) }

      before do
        user1.project_creators << creator2

        allow(NewProjectFinder).to receive(:find_creators_with_new_projects)
                                       .and_return([
                                                       {
                                                           project_creator: creator1,
                                                           new_projects: [project_hash]
                                                       },
                                                       {
                                                           project_creator: creator2,
                                                           new_projects: [project_hash]
                                                       }
                                                   ])
      end

      it 'should return a collection of users with all creators and their projects' do
        results = Notifier.new.build_user_notification_list

        expect(results).to include(
                               {
                                   user: user1,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       },
                                       {
                                           creator: creator2,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               }
                           )
      end
    end

    context 'when there are two users affected by one project creator' do
      let!( :user2 ) { FactoryGirl.create(:user) }

      before do
        user2.project_creators << creator1

        allow(NewProjectFinder).to receive(:find_creators_with_new_projects)
                                       .and_return([
                                                       {
                                                           project_creator: creator1,
                                                           new_projects: [project_hash]
                                                       }
                                                   ])
      end

      it 'should return a collection of users with all creators and their projects' do
        results = Notifier.new.build_user_notification_list

        expect(results).to match_array([
                               {
                                   user: user1,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               },
                               {
                                   user: user2,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               }
                           ])
      end
    end

    context 'when there are two users affected by two project creator' do
      let!( :user2 ) { FactoryGirl.create(:user) }
      let!( :creator2 ) { FactoryGirl.create(:project_creator) }

      before do
        user2.project_creators << creator1
        user2.project_creators << creator2

        allow(NewProjectFinder).to receive(:find_creators_with_new_projects)
                                       .and_return([
                                                       {
                                                           project_creator: creator1,
                                                           new_projects: [project_hash]
                                                       },
                                                       {
                                                           project_creator: creator2,
                                                           new_projects: [project_hash]
                                                       }
                                                   ])
      end

      it 'should return a collection of users with all creators and their projects' do
        results = Notifier.new.build_user_notification_list

        expect(results).to match_array([
                               {
                                   user: user1,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               },
                               {
                                   user: user2,
                                   new_projects_by_creators: [
                                       {
                                           creator: creator1,
                                           projects: [ project_hash ]
                                       },
                                       {
                                           creator: creator2,
                                           projects: [ project_hash ]
                                       }
                                   ]
                               }
                           ])
      end
    end
  end

  describe '#notify_users' do
    let( :notifier ) { Notifier.new }
    let( :build_user_notification_list_result ) do
      [
          {
              user: user1,
              new_projects_by_creators: [
                  {
                      creator: creator1,
                      projects: [ ]
                  }
              ]
          },
          {
              user: user2,
              new_projects_by_creators: [
                  {
                      creator: creator1,
                      projects: [ ]
                  },
                  {
                      creator: creator2,
                      projects: [ ]
                  }
              ]
          }
      ]
    end

    let!( :user1 ) { FactoryGirl.create(:user) }
    let!( :user2 ) { FactoryGirl.create(:user) }
    let!( :creator1 ) { FactoryGirl.create(:project_creator) }
    let!( :creator2 ) { FactoryGirl.create(:project_creator) }

    before do
      user2.project_creators << creator1
      user2.project_creators << creator2

      allow(notifier).to receive(:build_user_notification_list).and_return(build_user_notification_list_result)
      UserNotifier.delivery_method = :test
      UserNotifier.perform_deliveries = true
      UserNotifier.deliveries = []
    end

    after do
      UserNotifier.deliveries.clear
    end

    it 'should request an email for each user to be notified' do
      notifier.notify_users
      expect(UserNotifier.deliveries.count).to eq 2
    end
  end
end
