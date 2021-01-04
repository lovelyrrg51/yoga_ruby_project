class AddGpCategoryToGlobalPreference < ActiveRecord::Migration[5.0]
  def change
    add_column :global_preferences, :input_type, :integer
    add_column :global_preferences, :group_name, :integer
  end
end
