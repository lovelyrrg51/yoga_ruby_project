class CreateAdvisoryCounsils < ActiveRecord::Migration[5.1]
  def change
    create_table :advisory_counsils do |t|
      t.date :club_joining_date
      t.string :guest_email
      t.integer :sy_club_sadhak_profile_association_id
      t.datetime :deleted_at
      t.references :sadhak_profile, foreign_key: true
      t.references :sy_club, foreign_key: true

      t.timestamps
    end
    add_index :advisory_counsils, :deleted_at
  end
end
