# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  email      :string
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string
#

class User < ActiveRecord::Base
  has_and_belongs_to_many :project_creators
  has_secure_token
end
