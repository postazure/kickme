# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  password_digest :string
#  token           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ActiveRecord::Base
  has_and_belongs_to_many :project_creators, -> { uniq }
  has_secure_token
  has_secure_password
  validates :email, uniqueness: true, presence: true
end
