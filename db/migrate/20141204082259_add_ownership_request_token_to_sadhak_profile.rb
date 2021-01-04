class AddOwnershipRequestTokenToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :ownership_request_token, :string
  end
end
