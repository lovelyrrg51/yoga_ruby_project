class AddColumnIsUnderAgeToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :is_under_age, :boolean, default: false
  end
end
