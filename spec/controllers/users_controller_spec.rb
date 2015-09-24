require 'rails_helper'

describe UsersController do

  let( :project_creator ) { FactoryGirl.create(:project_creator)}
  let( :user ) { FactoryGirl.create(:user)}
  let( :payload ) do
    {
        project_creator: {
            kickstarter_id: project_creator.kickstarter_id
        }
    }
  end

  describe 'require auth' do
    let( :params ) { { token: 'badtoken' } }
    it 'should require auth for the following actions' do
      require_auth(:post, :follow, params )
      require_auth(:post, :unfollow, params )
      require_auth(:get, :project_creators, params )
    end
  end

  describe '#follow' do
      let( :new_project_creator ) do
        {
            project_creator: {
                kickstarter_id: 4242,
                name: 'foobar',
                profile_avatar: 'http://avatar',
                profile_url: 'http://profile',
                project: 'a project'
            }
        }
      end

      let( :profile_search_response ) { fixture('kickstarter/creator_lookup/coolminiornot.json') }


      before do
        stub_request(:get, 'http://profile')
            .to_return(body: profile_search_response)
      end


      it 'should add a project creator to the user\'s watch list and create the project creator' do
        expect(user.project_creators.count).to eq 0

        response = post :follow, new_project_creator.merge(token: user.token)
        body = JSON.parse(response.body)

        expect_normal_status(response)
        expect(body['follow']).to eq true
        expect(user.project_creators.count).to eq 1
        expect(user.project_creators.last.bio).to eq 'CoolMiniOrNot is both a studio and publisher of great tabletop games like Zombicide, Dark Age, Wrath of Kings, Rivet Wars, Kaosball, Dogs of War, Arcadia Quest, Xenoshyft and more! We work closely with game creators and indie studios to realize their vision, with a revenue sharing philosophy that is unprecedented in the industry.'
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

      expect_normal_status(response)
      expect(body['unfollow']).to eq true

      expect(user.project_creators.count).to eq 0
      expect(ProjectCreator.count).to eq 1
    end
  end

  describe '#project_creators' do
    before do
      user.project_creators << project_creator
      expect(user.project_creators.count).to eq 1
    end

    it 'should return a list of all project creators that this user follows' do
      response = get :project_creators, { token: user.token }
      response_body = JSON.parse(response.body)

      expect_normal_status(response)
      expect(response_body).to eq( [project_creator.as_json] )
    end
  end
end

def require_auth(method, action, params = {})
  response = send(method.to_s, action, params)
  expect(response.status).to eq 401
end

def expect_normal_status(response)
  expect(response.status).to eq 200
end