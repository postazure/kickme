class KickstarterProjectCreatorRepository
  attr_reader :name, :slug, :kickstarter_id, :avatar, :url_web,
              :url_api, :bio, :kickstarter_created_at,
              :created_project_count
  
  def initialize(json)
    @name = json['name']
    @slug = json['slug']
    @kickstarter_id = json['id']
    @avatar = json['avatar']['medium']
    @url_web = json['urls']['web']['user']
    @url_api = json['urls']['api']['user']
    @bio = json['biography']
    @kickstarter_created_at = json['created_at']
    @created_project_count = json['created_projects_count']
  end
end