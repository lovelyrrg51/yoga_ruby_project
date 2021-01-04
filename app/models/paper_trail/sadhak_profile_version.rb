class SadhakProfileVersion < PaperTrail::Version
  self.table_name = :sadhak_profile_versions
  self.sequence_name = :sadhak_profile_versions_id_seq
end
