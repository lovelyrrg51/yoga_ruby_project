class EventRegistrationVersion < PaperTrail::Version
  self.table_name = :event_registration_versions
  self.sequence_name = :event_registration_versions_id_seq
end
