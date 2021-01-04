class AddAvatarToSadhakProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :sadhak_profiles, :avatar, :string
  end
end
