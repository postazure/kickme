require 'spec_helper'
require 'json'
require_relative '../../app/repositories/kickstarter_project_creator_repository'

describe KickstarterProjectCreatorRepository do
  let( :creator_hash ) { JSON.parse(fixture('kickstarter/creator_lookup/coolminiornot.json')) }

  it '#initialize' do
    puts creator_hash
    creator = KickstarterProjectCreatorRepository.new(creator_hash)
    expect(creator.name).to eq 'CoolMiniOrNot'
  end
end