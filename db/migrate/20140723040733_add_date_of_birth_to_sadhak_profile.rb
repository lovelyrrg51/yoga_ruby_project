class AddDateOfBirthToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :date_of_birth, :date
  end
end
