module Api::V1
  class EventRegistrationsEventOrderDataSerializer < ActiveModel::Serializer
    attributes :id, :status, :transaction_id, :payment_method, :guest_email, :registration_center_user_id, :is_4_eye_verified, :reg_ref_number, :created_at
  end
end
