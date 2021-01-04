class EventOrderVersion < PaperTrail::Version
  self.table_name = :event_order_versions
  self.sequence_name = :event_order_versions_id_seq
end
