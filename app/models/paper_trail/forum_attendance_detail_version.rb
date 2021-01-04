class ForumAttendanceDetailVersion < PaperTrail::Version
  self.table_name = :forum_attendance_detail_versions
  self.sequence_name = :forum_attendance_detail_versions_id_seq
end
