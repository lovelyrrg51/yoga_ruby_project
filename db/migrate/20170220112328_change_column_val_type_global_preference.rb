class ChangeColumnValTypeGlobalPreference < ActiveRecord::Migration[5.0]
  def change
    change_column :global_preferences, :val, :text
  end
end
