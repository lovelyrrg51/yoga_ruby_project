class AddMobileVerificationTokenToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :mobile_verification_token, :string
  end
end
