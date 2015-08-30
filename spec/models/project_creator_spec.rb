require 'rails_helper'

describe ProjectCreator do
  describe 'relationships' do
    let( :user ) { FactoryGirl.create(:user) }
    let( :project_creator ) { FactoryGirl.create(:project_creator) }

    it 'users can follow many project_creators' do
      test_actions = lambda {
        project_creator.users << user
      }

      expect(test_actions).to change{user.project_creators.count}.from(0).to(1)
    end
  end
end