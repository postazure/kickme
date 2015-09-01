class KickstarterApiClient
  PROJECT_SEARCH_URL='https://www.kickstarter.com/projects/search.json?term=' #+'coolminiornot'

  def search_project_creators_by_name(name)
    response_body = get_response(PROJECT_SEARCH_URL + normalize_name(name))
    projects = JSON.parse(response_body)['projects']

    creators = []
    projects.each do |project|
      creators.push(
        {
          name: project['creator']['name'],
          kickstarter_id: project['creator']['id'],
          profile_url: project['creator']['urls']['api']['user'],
          profile_avatar: project['creator']['avatar']['medium']
        }
      )
    end
    creators.uniq
  end

  def get_creator_info_from_url(url)
    response_body = get_response(url)
    project_creator = JSON.parse(response_body)
    seconds_since_epoch = project_creator['created_at'].to_s
    translated_date = Date.strptime(seconds_since_epoch,'%s').to_s

    {
        name: project_creator['name'],
        slug: project_creator['slug'],
        kickstarter_id: project_creator['id'],
        avatar: project_creator['avatar']['medium'],
        url_web: project_creator['urls']['web']['user'],
        url_api: project_creator['urls']['api']['user'],
        bio: project_creator['biography'],
        created_project_count: project_creator['created_projects_count'],
        kickstarter_created_at: translated_date
    }
  end

  private

  def get_response(url)
    HTTParty.get(url).body
  end

  def normalize_name(name)
    name.gsub(/\s/, '+')
  end
end