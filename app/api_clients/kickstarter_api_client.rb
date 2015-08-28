class KickstarterApiClient
  PROJECT_SEARCH_URL='https://www.kickstarter.com/projects/search.json?term=' #+'coolminiornot'

  def search_project_creators_by_name(name)
    response = HTTParty.get(PROJECT_SEARCH_URL + normalize_name(name))
    projects = JSON.parse(response.body)['projects']

    creators = []
    projects.each do |project|
      creators.push(
        {
          name: project['creator']['name'],
          profile_url: project['creator']['urls']['api']['user'],
          profile_avatar: project['creator']['avatar']['medium']
        }
      )
    end
    creators.uniq
  end

  private

  def normalize_name(name)
    name.gsub(/\s/, '+')
  end
end