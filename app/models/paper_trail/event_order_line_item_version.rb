class EventOrderLineItemVersion < PaperTrail::Version
  self.table_name = :event_order_line_item_versions
  self.sequence_name = :event_order_line_item_versions_id_seq
end
