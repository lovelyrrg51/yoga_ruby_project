class AddColumnEditCountToForumAttendanceDetail < ActiveRecord::Migration
  def change
    add_column :forum_attendance_details, :edit_count, :integer, default: 0
  end
end
