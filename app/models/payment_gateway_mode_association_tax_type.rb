class PaymentGatewayModeAssociationTaxType < ApplicationRecord
  acts_as_paranoid

  validates :tax_type, :payment_gateway_mode_association, :percent, presence: true
  validates :percent, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  validates :tax_type, uniqueness: {scope: [:payment_gateway_mode_association]}

  scope :tax_type_id, ->(tax_type_id) { where(payment_gateway_mode_association_tax_types: {tax_type_id: tax_type_id}) }
  scope :payment_gateway_mode_association_id, ->(payment_gateway_mode_association_id) { where(payment_gateway_mode_association_tax_types: {payment_gateway_mode_association_id: payment_gateway_mode_association_id}) }

  delegate :name, to: :tax_type, prefix: 'tax_type', allow_nil: true

  belongs_to :tax_type
  belongs_to :payment_gateway_mode_association
end
