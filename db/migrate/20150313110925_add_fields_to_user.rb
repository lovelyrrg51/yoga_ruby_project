class AddFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_mobile_verified, :boolean, :default => false
    add_column :users, :is_email_verified, :boolean, :default => false
    add_column :users, :contact_number, :string
    add_column :users, :username, :string
    add_column :users, :sadhak_profile_id, :integer
  end
end
