class RenameLicenseColumnNamesInDoctorsProfile < ActiveRecord::Migration
  def change
    rename_column :doctors_profiles, :licence_status, :license_status
    rename_column :doctors_profiles, :licence_state_id, :license_state_id
    rename_column :doctors_profiles, :licence_country_id, :license_country_id
  end
end
