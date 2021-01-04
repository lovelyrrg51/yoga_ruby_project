class CreateForumAttendances < ActiveRecord::Migration
  def change
    create_table :forum_attendances do |t|
      t.references :sadhak_profile, index: true
      t.references :sy_club_member, index: true
      t.references :forum_attendance_detail, index: true
      t.boolean :is_attended, default: false
      t.datetime :deleted_at
      t.integer :last_updated_by
      t.boolean :is_current_forum_member

      t.timestamps
    end
    add_index :forum_attendances, :deleted_at
  end
end
