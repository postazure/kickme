require 'rails_helper'

describe ProjectCreatorsController do
  let!(:coolminiornot) { FactoryGirl.create(:project_creator, name: 'CoolMiniOrNot')}
  let!(:tmg)           { FactoryGirl.create(:project_creator, name: 'TMGgames')}

  describe '#index' do
    it 'should return all project creators from db' do
      expect(subject.index).to match_array(ProjectCreator.all)
    end
  end
end