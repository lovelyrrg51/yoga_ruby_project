class CreateSpiritualPractices < ActiveRecord::Migration
  def change
    create_table :spiritual_practices do |t|
      t.integer :morning_sadha_duration_hours
      t.integer :afternoon_sadha_duration_hours
      t.integer :evening_sadha_duration_hours
      t.integer :other_sadha_duration_hours
      t.integer :sadhana_frequency_days_per_week
      t.string :frequent_sadhana_type
      t.string :physical_exercise_type
      t.string :shivyog_teachings_applied_in_life #TODO: multiselect box, get info from ashram on content
      t.integer :sadhak_profile_id
      t.timestamps
    end
  end
end
