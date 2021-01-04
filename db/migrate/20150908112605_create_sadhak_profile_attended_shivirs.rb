class CreateSadhakProfileAttendedShivirs < ActiveRecord::Migration
  def change
    create_table :sadhak_profile_attended_shivirs do |t|
      t.string :shivir_name
      t.string :place
      t.string :month
      t.string :year
      t.references :sadhak_profile, index: true

      t.timestamps
    end
  end
end
