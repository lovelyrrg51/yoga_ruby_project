class ChangeColumnConductedOnToForumAttendanceDetail < ActiveRecord::Migration
  def change
    change_column :forum_attendance_details, :conducted_on, :datetime
  end
end
