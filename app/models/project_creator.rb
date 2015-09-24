# == Schema Information
#
# Table name: project_creators
#
#  id                     :integer          not null, primary key
#  name                   :string
#  slug                   :string
#  kickstarter_id         :integer
#  avatar                 :string
#  url_web                :string
#  url_api                :string
#  bio                    :text
#  created_project_count  :integer
#  kickstarter_created_at :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ProjectCreator < ActiveRecord::Base
  has_and_belongs_to_many :users

  validates_presence_of :project

  def kickstarter_api_client
    @kickstater_api_client ||= KickstarterApiClient.new
  end

  def as_json(*)
    serialize
  end

  def serialize
    {
        'name' => name,
        'kickstarter_id' => kickstarter_id,
        'avatar' => avatar,
        'url_web' => url_web,
        'bio' => bio,
        'created_project_count' => created_project_count,
        'kickstarter_created_at' => kickstarter_created_at.strftime('%m-%d-%Y')
    }
  end

  def update_url_api
    recent_project = self.project
    project_creator_hash = kickstarter_api_client
                          .search_project_creators_by_name(recent_project)
                          .find {|pc| kickstarter_id == pc[:kickstarter_id]}
    self.update(url_api: project_creator_hash[:profile_url])
  end
end
