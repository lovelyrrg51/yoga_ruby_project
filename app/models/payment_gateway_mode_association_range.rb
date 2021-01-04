class PaymentGatewayModeAssociationRange < ApplicationRecord
  acts_as_paranoid

  validates :min_value, :percent, :payment_gateway_mode_association, presence: true
  validates :percent, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}
  validates :min_value, numericality: {greater_than_or_equal_to: 0}

  scope :payment_gateway_id, ->(payment_gateway_id) { joins(:payment_gateway_mode_association).where(payment_gateway_mode_associations: {payment_gateway_id: payment_gateway_id}) }
  scope :payment_mode_id, ->(payment_mode_id) { joins(:payment_gateway_mode_association).where(payment_gateway_mode_associations: {payment_mode_id: payment_mode_id}) }
  scope :payment_gateway_mode_association_id, ->(payment_gateway_mode_association_id) { where(payment_gateway_mode_association_ranges: {payment_gateway_mode_association_id: payment_gateway_mode_association_id}) }

  belongs_to :payment_gateway_mode_association
  has_one :payment_gateway
  has_one :payment_mode
end
