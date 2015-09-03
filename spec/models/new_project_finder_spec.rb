require 'rails_helper'

describe NewProjectFinder do
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
end
