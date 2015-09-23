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

  describe 'validations' do
    let!( :user ) { FactoryGirl.create(:user, email: 'foo@bar.com') }
    it 'should have a unique email' do
      user_with_same_email = FactoryGirl.build(:user, email: 'foo@bar.com')
      expect(User.count).to eq 1
      user_with_same_email.save
      expect(User.count).to eq 1
    end

    it 'should require an email address' do
      user = FactoryGirl.build(:user, email: '')
      expect{user.save!}.to raise_exception
    end

    it 'should require a password' do
      user = FactoryGirl.build(:user, password: '')
      expect{user.save!}.to raise_exception
    end
  end

  describe 'encrypt password' do
    let!( :user ) {User.create(email: 'foo@bar.com', password: 'password', password_confirmation: 'password')}

    it 'should not store raw passwords' do
      expect(user.password_digest).not_to eq 'password'
    end
  end
end