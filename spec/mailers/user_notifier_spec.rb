require 'rails_helper'

describe UserNotifier do

  before do
    UserNotifier.delivery_method = :test
    UserNotifier.perform_deliveries = true
    UserNotifier.deliveries = []
  end

  after do
    UserNotifier.deliveries.clear
  end

  describe 'send_signup_email' do
    let( :user ) { FactoryGirl.create(:user) }

    before do
      UserNotifier.send_signup_email(user).deliver_now
    end

    it 'should send an email' do
      expect(UserNotifier.deliveries.count).to eq 1
    end

    it 'renders the receiver email' do
      expect(UserNotifier.deliveries.first.to).to eq [user.email]
    end

    it 'should set the subject to the correct subject' do
      expect(UserNotifier.deliveries.first.subject).to eq "Thanks for signing up, #{user.email}!"
    end

    it 'renders the sender email' do
      expect(UserNotifier.deliveries.first.from).to eq ['new_projects@mykickalerts.com']
    end
  end

  describe 'send_new_project_email' do
    let!( :user1 ) { FactoryGirl.create(:user) }
    let!( :creator1 ) { FactoryGirl.create(:project_creator) }

    let( :notification ) do
      {
          user: user1,
          new_projects_by_creators: [
              {
                  creator: creator1,
                  projects: [{
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
                             }]
              }
          ]
      }
    end

    it 'should notify users if project creators on the watch list add projects' do
      UserNotifier.send_new_project_email(notification).deliver_now

      expect(UserNotifier.deliveries.count).to eq 1
      expect(UserNotifier.deliveries.first.to).to eq [user1.email]
      expect(UserNotifier.deliveries.first.subject).to eq "#{creator1.name} Posted A New Project"
      expect(UserNotifier.deliveries.first.from).to eq ['new_projects@mykickalerts.com']
    end

    it 'should include the creators and their projects in the email' do
      UserNotifier.send_new_project_email(notification).deliver_now
      email_content = UserNotifier.deliveries.first.body.raw_source
      expect(email_content).to include(user1.email)
      expect(email_content).to include(creator1.name)
      expect(email_content).to include('creator1 project')
    end
  end
end