require 'rails_helper'

describe User do
  describe 'relationships' do
    let!( :user ) { FactoryGirl.create(:user) }
    let( :project_creator ) { FactoryGirl.create(:project_creator) }

    it 'users can follow many project_creators' do
      test_actions = lambda {
        user.project_creators << project_creator
      }

      expect(test_actions).to change{user.project_creators.count}.from(0).to(1)
    end

    it 'has no duplicate project_creators' do
      2.times { user.project_creators << project_creator }

      expect(user.project_creators.count).to eq 1
    end
  end

  describe 'encrypt password' do
    let!( :user ) {User.create(email: 'foo@bar.com', password: 'password', password_confirmation: 'password')}

    it 'should not store raw passwords' do
      expect(user.password_digest).not_to eq 'password'
    end
  end
end