module Api::V1
  class EventOrderSerializer < ActiveModel::Serializer
    attributes :id, :total_amount, :status, :transaction_id, :payment_method, :guest_email, :registration_center_user_id, :is_4_eye_verified, :user, :reg_ref_number, :created_at, :total_discount, :tax_details, :order_tax_detail
    #embed :ids
    has_one :user#, serializer: EventOrderUsersSerializer, include: true
    has_one :event#, include: true
  
    has_many :sadhak_profiles, serializer: EventOrderSadhakProfileSerializer, include: true
    #   has_many :event_registrations#, include: true
    has_one :registration_center, include: true
    has_many :event_order_line_items
  
    def tax_details
      if object.tax_details.present?
    	 object.tax_details.try(:except, 'details')
      end
    end
  end
end
