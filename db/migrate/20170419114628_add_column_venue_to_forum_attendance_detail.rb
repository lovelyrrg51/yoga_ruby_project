class AddColumnVenueToForumAttendanceDetail < ActiveRecord::Migration
  def change
    add_column :forum_attendance_details, :venue, :text, default: ''
  end
end
