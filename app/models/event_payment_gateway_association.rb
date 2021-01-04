class EventPaymentGatewayAssociation < ApplicationRecord
  include Filterable
  belongs_to :event, inverse_of: :event_payment_gateway_associations
  belongs_to :payment_gateway
  scope :event_id, ->(event_id) { where event_id: event_id }
end
