class ModifyAssociationsForRelationsTable < ActiveRecord::Migration
  def change
    remove_column :relations, :frist_name
    remove_column :relations, :middle_name
    remove_column :relations, :last_name
    remove_column :relations, :profession
    remove_column :relations, :relation_profile_id
    add_column :relations, :user_id, :integer
  end
end
