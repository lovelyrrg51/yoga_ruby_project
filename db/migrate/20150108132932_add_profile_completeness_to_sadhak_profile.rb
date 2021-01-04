class AddProfileCompletenessToSadhakProfile < ActiveRecord::Migration
  def change
    add_column :sadhak_profiles, :profile_completeness, :float, precision: 3, scale: 2
  end
end
