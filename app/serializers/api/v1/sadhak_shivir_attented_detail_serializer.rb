module Api::V1
  class SadhakShivirAttentedDetailSerializer < ActiveModel::Serializer
    attributes :event_id, :event_name, :reg_ref_number, :event_start_date
  
    def event_name
    	object.event.try(:event_name)
    end
  
    def reg_ref_number
    	object.event_order.try(:reg_ref_number)
    end
  
    def event_start_date
      return object.event.present? ? object.event.try(:event_start_date) : nil
    end
  
  end
end
