class AddProjectToProjectCreator < ActiveRecord::Migration
  def change
    add_column :project_creators, :project, :string
  end
end
