require 'rails_helper'

describe ProjectCreator do
  describe 'validations' do
    it 'should require a project' do
      pc = FactoryGirl.build(:project_creator, project: nil)
      expect{pc.save!}.to raise_exception
    end
  end

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

  describe '#update_url_api' do
    let!( :project_creator ) { FactoryGirl.create(:project_creator) }

    before do
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:search_project_creators_by_name)
          .and_return(
              [
                  {
                      kickstarter_id: project_creator.kickstarter_id,
                      profile_url: 'url with valid signature'
                  }
              ]
          )
    end

    it 'should update the project creators web_url with new signature' do
      outdated_web_url = project_creator.reload.url_api
      expect(project_creator.reload.url_api).to eq outdated_web_url

      project_creator.update_url_api
      expect(project_creator.reload.url_api).to eq 'url with valid signature'
    end
  end
end