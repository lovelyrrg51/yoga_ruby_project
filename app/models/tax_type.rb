class TaxType < ApplicationRecord
  default_scope { where(is_deleted: false) }

  has_many :event_tax_type_associations
  has_many :payment_gateway_mode_association_tax_types

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :tax_type_name, ->(tax_type_name) { where("name ILIKE ?", "%#{tax_type_name}%") }
end
