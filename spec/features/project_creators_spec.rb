require 'rails_helper'

xdescribe 'Project Creators' do
  describe 'View all creators' do
    let!(:creator) { FactoryGirl.create(:project_creator) }

    it 'should see all the project creator names in the db' do
      visit '/project_creators'
      expect(page).to have_content(creator.name)
    end
  end
end