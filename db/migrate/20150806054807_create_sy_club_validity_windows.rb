class CreateSyClubValidityWindows < ActiveRecord::Migration
  def change
    create_table :sy_club_validity_windows do |t|
      t.date :club_reg_start_date
      t.date :club_reg_end_date
      t.date :membership_start_date
      t.date :membership_end_date
      t.references :sy_club, index: true
      t.foreign_key :sy_clubs, column: :sy_club_id
      t.timestamps
    end
  end
end
