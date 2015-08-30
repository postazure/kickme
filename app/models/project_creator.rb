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


  def get_additional_profile_info
    additional_attr_hash = kickstarter_api_client.get_creator_info_from_url(url_api)
    self.assign_attributes(additional_attr_hash)
  end

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
end
