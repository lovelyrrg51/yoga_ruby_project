class AddColumnLastUpdatedByIdToForumAttendanceDetail < ActiveRecord::Migration
  def change
    add_column :forum_attendance_details, :last_updated_by_id, :integer
  end
end
