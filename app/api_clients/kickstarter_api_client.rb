class KickstarterApiClient
  PROJECT_SEARCH_URL='https://www.kickstarter.com/projects/search.json?term=' #+'coolminiornot'

  def search_project_creators_by_name(name)
    projects = get_projects_by_creator_name(name)

    creators = []
    projects.each do |project|
      project_creator_hash = project[:project_creator]
      creators.push(
        {
          name: project_creator_hash[:name],
          kickstarter_id: project_creator_hash[:kickstarter_id],
          profile_url: project_creator_hash[:profile_url],
          profile_avatar: project_creator_hash[:profile_avatar]
        }
      )
    end
    creators.uniq
  end

  def get_projects_by_creator_name(name)
    response_body = get_response(PROJECT_SEARCH_URL + normalize_name(name))
    projects = JSON.parse(response_body)['projects']

    projects.map do |project|
      {
          project_creator: {
            name: project['creator']['name'],
            kickstarter_id: project['creator']['id'],
            profile_url: project['creator']['urls']['api']['user'],
            profile_avatar: project['creator']['avatar']['medium']
          },
          project: {
              name: project['name'],
              blurb: project['blurb'],
              kickstarter_id: project['id'],
              pledged: project['pledged'],
              currency: project['currency'],
              state: project['state'],
              end_at: translate_date(project['deadline']),
              start_at: translate_date(project['launched_at']),
              image: project['photo']['med'],
              url_rewards: project['urls']['web']['rewards'],
              url_project: project['urls']['web']['project']

          }
      }
    end
  end

  def get_creator_info_from_url(url)
    response_body = get_response(url)
    project_creator = JSON.parse(response_body)
    {
        name: project_creator['name'],
        slug: project_creator['slug'],
        kickstarter_id: project_creator['id'],
        avatar: project_creator['avatar']['medium'],
        url_web: project_creator['urls']['web']['user'],
        url_api: project_creator['urls']['api']['user'],
        bio: project_creator['biography'],
        created_project_count: project_creator['created_projects_count'],
        kickstarter_created_at: translate_date(project_creator['created_at'])
    }
  end

  private

  def translate_date(seconds_since_epoch)
    Date.strptime(seconds_since_epoch.to_s, '%s').to_s
  end

  def get_response(url)
    HTTParty.get(url).body
  end

  def normalize_name(name)
    name.gsub(/\s/, '+')
  end
end