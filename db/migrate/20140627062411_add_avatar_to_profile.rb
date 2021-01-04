class AddAvatarToProfile < ActiveRecord::Migration
  def change
  	add_attachment :sadhak_profiles, :avatar
  end
end
