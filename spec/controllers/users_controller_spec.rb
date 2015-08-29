require 'rails_helper'

describe UsersController do
  describe '#follow' do
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

      expect(user.project_creators.count).to eq 0
    end

    it 'should require an auth token' do
      response = post :follow, payload

      expect(response.status).to eq 401
      expect(user.project_creators.count).to eq 0
    end

    it 'should add a project creator to the user\'s watch list' do
      response = post :follow, payload.merge(token: user.token)
      body = JSON.parse(response.body)

      expect(response.status).to eq 200
      expect(body['follow']).to eq true
      expect(user.project_creators.count).to eq 1
      expect(user.project_creators.first.name).to eq project_creator.name
    end
  end
end
