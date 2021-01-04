class AddIsDeletedToGlobalPreference < ActiveRecord::Migration
  def change
    add_column :global_preferences, :is_deleted, :boolean, default: :false
  end
end
