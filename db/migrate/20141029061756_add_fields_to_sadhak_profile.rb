class AddFieldsToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :mobile, :string
    add_column :sadhak_profiles, :phone, :string
    add_column :sadhak_profiles, :email, :string
    add_column :sadhak_profiles, :is_mobile_verified, :boolean, :default => false
    add_column :sadhak_profiles, :address_id, :integer, :references => [:addresses, :id]
  end
end
