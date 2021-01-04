class CreateForumAttendanceDetails < ActiveRecord::Migration
  def change
    create_table :forum_attendance_details do |t|
      t.references :digital_asset, index: true
      t.references :sy_club, index: true
      t.date :conducted_on
      t.integer :creator_id
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :forum_attendance_details, :deleted_at
    add_index :forum_attendance_details, [:digital_asset_id, :sy_club_id, :conducted_on], name: 'index_forum_attendancedetails_on_d_asset_id_c_id_conducted_on'
  end
end
