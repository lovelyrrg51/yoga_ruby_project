class PaymentGateway < ApplicationRecord
  include Filterable
  scope :payment_gateway_type_id, ->(payment_gateway_type_id) { where payment_gateway_type_id: payment_gateway_type_id }
  scope :event_id, ->(event_id) { joins(:events).where('event_payment_gateway_associations.event_id = ?', event_id) }

  scope :payment_gateway_type_id, ->(payment_gateway_type_id) { where('payment_gateway_type_id = ?', payment_gateway_type_id) }

  belongs_to :payment_gateway_type
  has_many :event_payment_gateway_associations, dependent: :destroy
  has_many :events, :through => :event_payment_gateway_associations
  has_one :pg_sydd_config
  has_one :ccavenue_config
  has_one :hdfc_config
  has_one :stripe_config
  has_one :pg_sy_razorpay_config
  has_one :pg_sy_braintree_config
  has_one :pg_sy_paypal_config
  has_one :pg_sy_payfast_config
  has_many :sy_club_payment_gateway_associations
  has_many :sy_clubs, :through => :sy_club_payment_gateway_associations
  has_many :payment_gateway_mode_associations, dependent: :destroy
  has_many :payment_modes, through: :payment_gateway_mode_associations
end
