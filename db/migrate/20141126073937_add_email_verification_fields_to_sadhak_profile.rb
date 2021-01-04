class AddEmailVerificationFieldsToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :is_email_verified, :boolean
    add_column :sadhak_profiles, :email_verification_token, :string
  end
end
