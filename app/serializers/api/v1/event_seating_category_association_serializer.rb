module Api::V1
  class EventSeatingCategoryAssociationSerializer < ActiveModel::Serializer
    attributes :id, :price, :seating_capacity, :seats_available, :cancellation_charge, :extra_seat_alloted
    #embed :ids
    has_one :event
    has_one :seating_category, include: true
    
    def seats_available
      if !object.seating_capacity.nil?
        total_seats = object.seating_capacity
        # seats_occupied = object.event.event_registrations.where(event_seating_category_association_id:  object.id).all.count
        # seats_occupied = EventRegistration.where(event_seating_category_association_id:  object.id, event_id: object.event.id).all.count
        # seats_occupied = object.event_registrations.select{ |r| EventRegistration.valid_registration_statuses.include?(EventRegistration.statuses[r.status]) }.size
        seats_occupied = EventRegistration.where(status: EventRegistration.valid_registration_statuses, event_seating_category_association_id: object.id, event_id: object.event_id).size
  
        return total_seats - seats_occupied < 0 ? 0 : total_seats - seats_occupied
      end
    end
    
    def extra_seat_alloted
      # return object.event_registrations.select{ |r| r.is_extra_seat? }.size
      # return object.event_registrations.select{ |r| EventRegistration.valid_registration_statuses.include?(EventRegistration.statuses[r.status]) and r.is_extra_seat? }.size
      return EventRegistration.where(status: EventRegistration.valid_registration_statuses, event_seating_category_association_id: object.id, event_id: object.event_id, is_extra_seat: true).size
    end
    
    def price
      @price = '%.2f' % object.price 
    end
    
    # def others
    #   seats_occupied = EventRegistration.where(event_seating_category_association_id: object.id, event_id: object.event.id, status: [nil, EventRegistration.statuses['updated']]).where.not(created_by: nil).all.count
    # end
  end
end
