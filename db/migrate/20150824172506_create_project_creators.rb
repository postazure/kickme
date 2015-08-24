class CreateProjectCreators < ActiveRecord::Migration
  def change
    create_table :project_creators do |t|
      t.string :name
      t.string :slug
      t.integer :kickstarter_id
      t.string :avatar
      t.string :url
      t.text :bio
      t.integer :created_project_count
      t.string :kickstarter_created_at

      t.timestamps null: false
    end
  end
end
