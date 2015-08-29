require 'rails_helper'

describe User do
  describe 'relationships' do
    let!( :user ) { FactoryGirl.create(:user) }
    let( :project_creator ) { FactoryGirl.create(:project_creator) }

    before do
      using_project_creator_factory
      project_creator
    end

    it 'users can follow many project_creators' do
      test_actions = lambda {
        user.project_creators << project_creator
      }

      expect(test_actions).to change{user.project_creators.count}.from(0).to(1)
    end
  end
end