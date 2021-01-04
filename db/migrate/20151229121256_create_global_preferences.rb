class CreateGlobalPreferences < ActiveRecord::Migration
  def change
    create_table :global_preferences do |t|
      t.string :key
      t.string :val

      t.timestamps
    end
  end
end
