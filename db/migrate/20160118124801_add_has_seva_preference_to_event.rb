class AddHasSevaPreferenceToEvent < ActiveRecord::Migration
  def change
    add_column :events, :has_seva_preference, :boolean, default: :false
  end
end
