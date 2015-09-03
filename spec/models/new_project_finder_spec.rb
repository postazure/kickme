require 'rails_helper'

describe NewProjectFinder do
  describe '#new_project?' do
    let( :project_count ) { 20 }
    let( :new_project_count ) { project_count + 1 }
    let( :project_creator ) { FactoryGirl.build(:project_creator, kickstarter_id: 100, created_project_count: project_count) }

    before do
      allow_any_instance_of(KickstarterApiClient).to receive(:get_creator_info_from_url).and_return({ created_project_count: new_project_count })
      project_creator.save!
    end

    it 'should see if the project count changes for a project creator' do
      finder = NewProjectFinder.new(project_creator)
      expect(finder.new_project?).to be true
    end

    it 'should update the created project count' do
      finder = NewProjectFinder.new(project_creator)
      finder.new_project?

      expect(project_creator.reload.created_project_count).to eq new_project_count
    end
  end

  describe '.find_creators_with_new_projects' do
    let!( :creators_with_new_projects ) do
      [
          FactoryGirl.create(:project_creator, created_project_count: 3, url_api: 'creator1_url'),
          FactoryGirl.create(:project_creator, created_project_count: 5, url_api: 'creator2_url')
      ]
    end

    before do
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with('creator1_url')
          .and_return({ created_project_count: 4 })
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with('creator2_url')
          .and_return({ created_project_count: 6 })
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with('creator3_url')
          .and_return({ created_project_count: 7 })

      FactoryGirl.create(:project_creator, created_project_count: 7, url_api: 'creator3_url')
    end

    it 'should return all project creators that have new projects' do
      creators = NewProjectFinder.find_creators_with_new_projects
      expect(creators).to match_array(creators_with_new_projects)
    end

    it 'should figure out what the new project is and return it with the creator' do
      raise 'Make this test a reality'
    end
  end
end