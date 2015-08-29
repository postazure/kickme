class CreateJoinTableUserProjectCreator < ActiveRecord::Migration
  def change
    create_join_table :users, :project_creators do |t|
      # t.index [:user_id, :project_creator_id]
      # t.index [:project_creator_id, :user_id]
    end
  end
end
