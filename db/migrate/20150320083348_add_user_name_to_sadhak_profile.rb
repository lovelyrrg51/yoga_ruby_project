class AddUserNameToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :username, :string
  end
end
