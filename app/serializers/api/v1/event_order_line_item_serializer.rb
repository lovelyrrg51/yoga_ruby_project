module Api::V1
  class EventOrderLineItemSerializer < ActiveModel::Serializer
  
    attributes :id, :sadhak_profile_id, :syid, :seating_category_id, :transferred_ref_number, :first_name, :event_id, :event_seating_category_association_id, :registration_number, :status, :is_extra_seat, :event_type_pricing_id, :discount, :price, :available_for_seva, :expiration_date
    
    def first_name
      object.try(:sadhak_profile).try(:first_name)
    end
    
    def syid
      object.try(:sadhak_profile).try(:syid)
    end
    
    def seating_category_id
      object.try(:event_seating_category_association).try(:seating_category_id)
    end
    
    def event_id
      if object.event_seating_category_association.present?
        object.event_seating_category_association.event_id
      else
        object.event_order.event_id
      end
    end
  
    def registration_number
      if object.event_registration.present? and object.event.sy_event_company_id.present?
        res = object.event_registration.serial_number + 100
      else
        res = object.registration_number
      end
      return res
    end
  
    #embed :ids
    has_one :payment_refund_line_item
    
  end
end
