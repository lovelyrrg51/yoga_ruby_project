class SourceInfoType < ApplicationRecord
  default_scope { where(is_deleted: false) }

  validates :source_name, presence: true
  validates_uniqueness_of :source_name, conditions: lambda { where(is_deleted: false) }, case_sensitive: false

  has_many :sub_source_types,  dependent: :destroy

  before_update :update_dependent, if: :is_deleted_changed?

  scope :source_info_type_name, ->(source_info_type_name) { where("source_name ILIKE ?", "%#{source_info_type_name}%" ) }

  private
  def update_dependent
    sub_source_types = self.sub_source_types.unscoped.where(source_info_type_id: self.id)
    count = sub_source_types.count
    errors.add(:there, "is some error while deleting sub source types.") if count != sub_source_types.update_all(is_deleted: self.is_deleted)
  end
end
