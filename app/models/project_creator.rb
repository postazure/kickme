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
#  kickstarter_created_at :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ProjectCreator < ActiveRecord::Base
  has_and_belongs_to_many :users
  before_save :get_additional_profile_info

  def get_additional_profile_info
    additional_attr_hash = kickstarter_api_client.get_creator_info_from_url(url_api)
    self.assign_attributes(additional_attr_hash)

    return true # Must return truthy to allow save.
  end

  def kickstarter_api_client
    @kickstater_api_client ||= KickstarterApiClient.new
  end
end
