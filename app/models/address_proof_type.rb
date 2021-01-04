class AddressProofType < ApplicationRecord
  validates :name, presence: true,
    length: { minimum: 3 },
    uniqueness: { case_sensitive: false }

  scope :address_proof_type_name, ->(address_proof_type_name) { where("name ILIKE ?", "%#{address_proof_type_name}%") }
end
