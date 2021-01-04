class ForumAttendanceVersion < PaperTrail::Version
  self.table_name = :forum_attendance_versions
  self.sequence_name = :forum_attendance_versions_id_seq
end
