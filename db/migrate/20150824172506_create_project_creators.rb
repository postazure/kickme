class CreateProjectCreators < ActiveRecord::Migration
  def change
    create_table :project_creators do |t|
      t.string :name
      t.string :slug
      t.integer :kickstarter_id
      t.string :avatar
      t.string :url_web
      t.string :url_api
      t.text :bio
      t.integer :created_project_count
      t.datetime :kickstarter_created_at

      t.timestamps null: false
    end
  end
end
