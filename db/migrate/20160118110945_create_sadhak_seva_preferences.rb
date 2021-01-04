class CreateSadhakSevaPreferences < ActiveRecord::Migration
  def change
    create_table :sadhak_seva_preferences do |t|
      t.text :voluntary_organisation
      t.integer :seva_preference
      t.string :other_seva_preference
      t.integer :availability
      t.integer :sadhak_profile_id
      t.string :expertise

      t.timestamps
    end
  end
end
