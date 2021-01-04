module Api::V1
  class OrderPaymentInformationSerializer < ActiveModel::Serializer
    attributes :id, :amount, :billing_name, :billing_address, :billing_address_city, :billing_address_postal_code, :billing_address_country, :billing_phone, :billing_email, :ccavenue_tracking_id, :ccavenue_failure_message, :ccavenue_payment_mode, :ccavenue_status_code, :ccavenue_status_identifier, :billing_address_state, :status, :created_at, :updated_at
    #embed :ids
    has_one :event_order
  end
end
