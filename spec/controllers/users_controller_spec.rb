require 'rails_helper'

describe UsersController do
  describe 'require auth' do
    it 'should require auth for the following actions' do
      require_auth(:follow)
      require_auth(:unfollow)
    end
  end

  let( :project_creator ) { FactoryGirl.create(:project_creator)}
  let( :user ) { FactoryGirl.create(:user)}
  let( :payload ) do
    {
        project_creator: {
            kickstarter_id: project_creator.kickstarter_id
        }
    }
  end

  before do
    using_project_creator_factory
    project_creator
  end

  describe '#follow' do
    it 'should add a project creator to the user\'s watch list' do
      expect(user.project_creators.count).to eq 0

      response = post :follow, payload.merge(token: user.token)
      body = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(body['follow']).to eq true
      expect(user.project_creators.count).to eq 1
      expect(user.project_creators.first.name).to eq project_creator.name
    end
  end

  describe '#unfollow' do
    before do
      user.project_creators << project_creator
      expect(user.project_creators.count).to eq 1
    end

    it 'should remove a project creator form a user\'s watch list' do
      response = post :unfollow, payload.merge(token: user.token)
      body = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(body['unfollow']).to eq true

      expect(user.project_creators.count).to eq 0
      expect(ProjectCreator.count).to eq 1
    end
  end
end

def require_auth(action)
  response = post action
  expect(response.status).to eq 401
end