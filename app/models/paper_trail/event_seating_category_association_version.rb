class EventSeatingCategoryAssociationVersion < PaperTrail::Version
  self.table_name = :event_seating_category_association_versions
  self.sequence_name = :event_seating_category_association_versions_id_seq
end
