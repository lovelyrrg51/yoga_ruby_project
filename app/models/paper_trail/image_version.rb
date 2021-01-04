class ImageVersion < PaperTrail::Version
  self.table_name = :image_versions
  self.sequence_name = :image_versions_id_seq
end
