require 'rails_helper'

describe NewProjectFinder do
  describe '.find_creators_with_new_projects' do
    let!( :creator1 ) { FactoryGirl.create(:project_creator, created_project_count: 1) }
    let!( :creator2 ) { FactoryGirl.create(:project_creator, created_project_count: 1) }
    let!( :creator3 ) { FactoryGirl.create(:project_creator, created_project_count: 1) }
    let( :creator1_project ) do
      {
              name: 'The New Project',
              blurb: 'It be new, buy it!',
              kickstarter_id: 2231771828,
              pledged: 88259,
              currency: 'USD',
              state: 'successful',
              end_at: '2015-10-01',
              start_at: '2015-08-01',
              image: 'https://image',
              url_rewards: 'https://www.rewards',
              url_project: 'https://www.project'
      }
    end
    let( :creator2_project1 ) do
      {
              name: 'creator2_project1',
              blurb: 'It be new, buy it!',
              kickstarter_id: 1771828,
              pledged: 88259,
              currency: 'USD',
              state: 'successful',
              end_at: '2015-10-01',
              start_at: '2015-08-02',
              image: 'https://image',
              url_rewards: 'https://www.rewards',
              url_project: 'https://www.project'
      }
    end
    let( :creator2_project2 ) do
      {
              name: 'creator2_project2',
              blurb: 'It be new, buy it!',
              kickstarter_id: 2771828,
              pledged: 88259,
              currency: 'USD',
              state: 'successful',
              end_at: '2015-10-01',
              start_at: '2015-08-01',
              image: 'https://image',
              url_rewards: 'https://www.rewards',
              url_project: 'https://www.project'
      }
    end
    let( :pc1_newest_return ) do
      [
          {
              project_creator: {
                  name: creator1.name,
                  kickstarter_id: creator1.kickstarter_id,
                  profile_url: creator1.url_api,
                  profile_avatar: creator1.avatar
              },
              project: creator1_project
          }
      ]
    end
    let( :pc2_newest_return ) do
      [
          {
              project_creator: {
                  name: creator2.name,
                  kickstarter_id: creator2.kickstarter_id,
                  profile_url: creator2.url_api,
                  profile_avatar: creator2.avatar
              },
              project: creator2_project1
          },
          {
              project_creator: {
                  name: creator2.name,
                  kickstarter_id: creator2.kickstarter_id,
                  profile_url: creator2.url_api,
                  profile_avatar: creator2.avatar
              },
              project: creator2_project2
          }
      ]
    end

    before do
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with(creator1.url_api)
          .and_return(created_project_count: creator1.created_project_count + 1)
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with(creator2.url_api)
          .and_return(created_project_count: creator2.created_project_count + 2)
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:get_creator_info_from_url)
          .with(creator3.url_api)
          .and_return(created_project_count: creator3.created_project_count + 0)

      allow_any_instance_of(NewProjectFinder)
          .to receive(:get_newest_projects_with_creator)
          .with(1)
          .and_return(pc1_newest_return)
      allow_any_instance_of(NewProjectFinder)
          .to receive(:get_newest_projects_with_creator)
          .with(2)
          .and_return(pc2_newest_return)
    end

    it 'should return all project creators that have new projects' do
      creators = NewProjectFinder.find_creators_with_new_projects
      expect(creators).to match_array(
          [
              {
                  project_creator: creator1,
                  new_projects: [creator1_project]
              },
              {
                  project_creator: creator2,
                  new_projects: [creator2_project1, creator2_project2]
              }
          ]
      )
    end

    it 'should not include project creators that do not have new projects' do
      creators = NewProjectFinder.find_creators_with_new_projects
      expect(creators).not_to include(creator3)
    end
  end

  describe '#new_project_count' do
    let( :project_count ) { 20 }
    let( :new_project_count ) { project_count + 2 }
    let( :project_creator ) { FactoryGirl.build(:project_creator, kickstarter_id: 100, created_project_count: project_count) }

    before do
      allow_any_instance_of(KickstarterApiClient).to receive(:get_creator_info_from_url).and_return({ created_project_count: new_project_count })
      project_creator.save!
    end

    it 'should return the number of new projects a creator posts' do
      finder = NewProjectFinder.new(project_creator)
      expect(finder.new_project_count).to eq 2
    end

    it 'should update the created project count' do
      finder = NewProjectFinder.new(project_creator)
      finder.new_project_count

      expect(project_creator.reload.created_project_count).to eq new_project_count
    end
  end

  describe '#get_newest_projects_with_creator' do
    let( :project_creator ) { FactoryGirl.create(:project_creator, kickstarter_id: 1134494596) }
    let( :project_list ) do
      [
          {
              project_creator: {
                  name: 'CoolMiniOrNot',
                  kickstarter_id: 1134494596,
                  profile_url: 'http://profile',
                  profile_avatar: 'https://avatar'
              },
              project: {
                  name: 'The New Project',
                  blurb: 'It be new, buy it!',
                  kickstarter_id: 2231771828,
                  pledged: 88259,
                  currency: 'USD',
                  state: 'successful',
                  end_at: '2015-10-01',
                  start_at: '2015-08-01',
                  image: 'https://image',
                  url_rewards: 'https://www.rewards',
                  url_project: 'https://www.project'
              }
          },
          {
              project_creator: {
                  kickstarter_id: 1134494596,
              },
              project: {
                  name: 'CoolMiniOrNot Base System Featuring Micro Art Studio',
                  blurb: 'Beautiful, affordable terrain bases for all your miniatures!',
                  kickstarter_id: 1231771828,
                  pledged: 88259,
                  currency: 'USD',
                  state: 'successful',
                  end_at: '2014-10-05',
                  start_at: '2014-09-19',
                  image: 'https://image',
                  url_rewards: 'https://www.rewards',
                  url_project: 'https://www.project'
              }
          }
      ]
    end

    context 'when on the project creator\'s projects will not show up' do

      before do
        allow_any_instance_of(KickstarterApiClient).to receive(:get_projects_by_creator_name)
                                                           .with(project_creator.slug)
                                                           .and_return(project_list.reverse)
      end

      it 'should get the information for new projects' do
        finder = NewProjectFinder.new(project_creator)
        results = finder.get_newest_projects_with_creator(1)
        expect(results).to eq(
                               [
                                   {
                                     project_creator: {
                                         name: 'CoolMiniOrNot',
                                         kickstarter_id: 1134494596,
                                         profile_url: 'http://profile',
                                         profile_avatar: 'https://avatar'
                                     },
                                     project: {
                                         name: 'The New Project',
                                         blurb: 'It be new, buy it!',
                                         kickstarter_id: 2231771828,
                                         pledged: 88259,
                                         currency: 'USD',
                                         state: 'successful',
                                         end_at: '2015-10-01',
                                         start_at: '2015-08-01',
                                         image: 'https://image',
                                         url_rewards: 'https://www.rewards',
                                         url_project: 'https://www.project'
                                     }
                                 }
                               ]
                           )
      end

      it 'should get the information for (n) new projects' do
        finder = NewProjectFinder.new(project_creator)
        results = finder.get_newest_projects_with_creator(2)
        expect(results.length).to eq 2
      end
    end

    context 'when other project creator\'s projects could show up' do

      let( :other_creators_project ) do
        {
            project_creator: {
                kickstarter_id: 12,
            },
            project: {
                name: 'Another Creator Made This',
                blurb: 'Not Good',
                kickstarter_id: 200,
                pledged: 88259,
                currency: 'USD',
                state: 'successful',
                end_at: '2015-10-05',
                start_at: '2015-08-02',
                image: 'https://image',
                url_rewards: 'https://www.rewards',
                url_project: 'https://www.project'
            }
        }
      end

      before do
        allow_any_instance_of(KickstarterApiClient).to receive(:get_projects_by_creator_name)
           .with(project_creator.slug)
           .and_return(project_list.unshift(other_creators_project))
      end

      it 'should not include projects by other creators' do
        finder = NewProjectFinder.new(project_creator)
        results = finder.get_newest_projects_with_creator(2)
        expect(results).not_to include(other_creators_project)
      end
    end

  end

  describe '.update_creator_api_signatures' do
    let!( :project_creator ) { FactoryGirl.create(:project_creator) }

    before do
      allow_any_instance_of(KickstarterApiClient)
          .to receive(:search_project_creators_by_name)
          .with(project_creator.project)
          .and_return(
              [
                  {
                      kickstarter_id: project_creator.kickstarter_id,
                      profile_url: 'url with valid signature'
                  }
              ]
          )
    end

    it 'should find the new user link for the creator' do
      NewProjectFinder.update_creator_api_signatures
      expect(project_creator.reload.url_api).to eq 'url with valid signature'
    end
  end
end
