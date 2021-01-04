class SubSourceType < ApplicationRecord
  default_scope { where(is_deleted: false) }

  belongs_to :source_info_type

  validates :source_info_type_id, :sub_source_name, presence: true
  validates_uniqueness_of :sub_source_name, scope: :source_info_type_id, conditions: lambda { where(is_deleted: false) }, case_sensitive: false

  scope :source_info_type_id, lambda { |source_info_type_id| where(source_info_type_id: source_info_type_id) }
end
