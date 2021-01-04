class AddFullProfileNeededToEvent < ActiveRecord::Migration
  def change
    add_column :events, :full_profile_needed, :boolean, default: :false
  end
end
