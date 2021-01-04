class Admin

  def self.build
    new
  end

  def merge_event_registrations(primary, secondary, merge_ref_number)

    raise 'Event Registartion: Primary sadhak cannot be blank.' unless primary.present?

    raise 'Event Registartion: Secondary sadhak cannot be blank.' unless secondary.present?

    raise 'Event Registartion: Merge reference number cannot be blank.' unless merge_ref_number.present?

    primary = primary.reload

    secondary = secondary.reload

    mergable_event_registration_ids = secondary.event_registrations.where('status IN (?) AND event_id NOT IN (?)', EventRegistration.valid_registration_statuses, Event.clp_event_ids + primary.event_ids).pluck(:id)

    create_registrations(mergable_event_registration_ids, primary.id, merge_ref_number)

    mergable_event_registration_ids

  end

  def merge_sy_club_members(primary, secondary, merge_ref_number)

    raise 'Event Registartion: Primary sadhak cannot be blank.' unless primary.present?

    raise 'Event Registartion: Secondary sadhak cannot be blank.' unless secondary.present?

    raise 'Event Registartion: Merge reference number cannot be blank.' unless merge_ref_number.present?

    primary = primary.reload

    secondary = secondary.reload

    primary_forum_memberships = primary.forum_memberships

    secondary_forum_memberships = secondary.forum_memberships

    secondary_forum_membership_ids = []

    raise "#{primary.syid}-#{primary.full_name} is registered on more than one forum." if primary_forum_memberships.size > 1

    raise "#{secondary.syid}-#{secondary.full_name} is registered on more than one forum." if secondary_forum_memberships.size > 1

    if primary_forum_memberships.size == 0 && secondary_forum_memberships.size > 0

      create_registrations(secondary_forum_memberships.pluck(:event_registration_id), primary.id, merge_ref_number)

      secondary_forum_membership_ids = secondary_forum_memberships.pluck(:id)

    end

    secondary_forum_membership_ids

  end

  def merge_sy_club_sadhak_profile_associations(primary, secondary, merge_ref_number)

    raise 'Event Registartion: Primary sadhak cannot be blank.' unless primary.present?

    raise 'Event Registartion: Secondary sadhak cannot be blank.' unless secondary.present?

    raise 'Event Registartion: Merge reference number cannot be blank.' unless merge_ref_number.present?

    primary = primary.reload

    secondary = secondary.reload

    secondary_sy_club_sadhak_profile_association_ids = []

    primary_sy_club_sadhak_profile_associations = primary.sy_club_sadhak_profile_associations

    secondary_sy_club_sadhak_profile_associations = secondary.sy_club_sadhak_profile_associations

    raise "#{primary.syid}-#{primary.full_name} is board member of more than one forum." if primary_sy_club_sadhak_profile_associations.size > 1

    raise "#{secondary.syid}-#{secondary.full_name} is board member of more than one forum." if secondary_sy_club_sadhak_profile_associations.size > 1

    if primary_sy_club_sadhak_profile_associations.size == 0 && secondary_sy_club_sadhak_profile_associations.size > 0

      secondary_sy_club_sadhak_profile_association_ids = secondary_sy_club_sadhak_profile_associations.collect(&:id)

      secondary_sy_club_sadhak_profile_associations.first.update!(sadhak_profile_id: primary.id)

    end

    secondary_sy_club_sadhak_profile_association_ids

  end

  private

  def create_registrations(event_registration_ids, sadhak_profile_id, merge_ref_number)

    event_registrations = EventRegistration.where(id: event_registration_ids)

    return unless sadhak_profile_id.present? && event_registrations.present?

    event_registrations.each do |event_registration|

      line_item = event_registration.event_order_line_item

      _event_order = event_registration.event_order

      # Create event order, line item and registrations
      event_order = EventOrder.new(event_id: _event_order.event_id, guest_email: _event_order.guest_email, is_guest_user: true, payment_method: 'No Payment', status: EventOrder.statuses['success'], transaction_id: "MERGE-SYID-#{merge_ref_number}", sy_club_id: _event_order.sy_club_id, user: $current_user)

      event_order.save!

      EventOrderLineItem.without_callbacks(:assign_line_item_id_to_special_event_sadhak_profile_other_info) do

        @event_order_line_item = EventOrderLineItem.new(event_order_id: event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: line_item.seating_category_id, event_seating_category_association_id: line_item.event_seating_category_association_id, price: line_item.price)

        @event_order_line_item.save!

      end

      EventRegistration.without_callbacks(:notify_registration) do

        @event_registration = EventRegistration.new(event_order_id: event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: event_registration.event_seating_category_association_id, event_id: event_registration.event_id, event_order_line_item_id: @event_order_line_item.id, user: $current_user)

        @event_registration.save!

        # Assign remaining days to registration in case of forum membership registration.

        if _event_order.sy_club_id.present?

          expires_at = event_registration.get_remaining_days

          expires_at > 0 && @event_registration.update_columns(expires_at: expires_at)

        end

      end

    end

  end

end
