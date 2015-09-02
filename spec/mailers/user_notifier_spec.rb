require 'rails_helper'

describe UserNotifier do
  let( :user ) { FactoryGirl.create(:user) }

  before do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    UserNotifier.send_signup_email(user).deliver_now
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  it 'should send an email' do
    expect(ActionMailer::Base.deliveries.count).to eq 1
  end

  it 'renders the receiver email' do
    expect(ActionMailer::Base.deliveries.first.to).to eq [user.email]
  end

  it 'should set the subject to the correct subject' do
    expect(ActionMailer::Base.deliveries.first.subject).to eq "Thanks for signing up, #{user.email}!"
  end

  it 'renders the sender email' do
    expect(ActionMailer::Base.deliveries.first.from).to eq ['new_projects@mykickalerts.com']
  end
end