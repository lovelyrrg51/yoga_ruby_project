class AddAliasNameToGlobalPreference < ActiveRecord::Migration
  def change
    add_column :global_preferences, :alias_name, :string
  end
end
