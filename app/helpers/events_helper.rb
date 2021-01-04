module EventsHelper

  def cumulative_reg_fee(event_categories = [], selected_categories = [])
    event_categories.select{|ec| selected_categories.include?(ec.id.to_s)}.collect{|ec| ec.price}.reduce(&:+).rnd
  end

  def cumulative_photo_and_photo_id_status_text(sadhak_profile)

    if sadhak_profile.present? && sadhak_profile.advance_profile.present? && sadhak_profile.advance_profile.advance_profile_photograph.present? && sadhak_profile.advance_profile.advance_profile_identity_proof.present?

      if sadhak_profile.pp_success? && sadhak_profile.pi_success?
        'Approved'
      elsif sadhak_profile.pp_rejected? && sadhak_profile.pi_rejected?
        'Rejected'
      else
        'Pending'
      end

    else
      'Not Available'
    end

  end


  def cumulative_photo_and_photo_id_status_class(sadhak_profile)

    if sadhak_profile.present? && sadhak_profile.advance_profile.present? && sadhak_profile.advance_profile.advance_profile_photograph.present? && sadhak_profile.advance_profile.advance_profile_identity_proof.present?

      if sadhak_profile.pp_success? && sadhak_profile.pi_success?
        'green'
      elsif sadhak_profile.pp_rejected? && sadhak_profile.pi_rejected?
        'red'
      else
        'orange'
      end

    else
      'orange'
    end

  end

  def cumulative_photo_and_photo_id_status_rails_class(sadhak_profile)

    if sadhak_profile.present? && sadhak_profile.advance_profile.present? && sadhak_profile.advance_profile.advance_profile_photograph.present? && sadhak_profile.advance_profile.advance_profile_identity_proof.present?

      if sadhak_profile.pp_success? && sadhak_profile.pi_success?
        'approved'
      elsif sadhak_profile.pp_rejected? && sadhak_profile.pi_rejected?
        'rejected'
      else
        'pending'
      end

    else
      'not_available'
    end

  end

  def rejection_reasons

    if @reasons.present? && @reasons.size > 0
      return @reasons
    end

    @reasons = []

    @reasons = GlobalPreference.get_value_of('photo_and_photo_id_rejection_reasons').to_s.split(',')

    @reasons
  end

  def event_registration_status_color_class(event_registration)

    if event_registration.success?
      'green'
    elsif event_registration.cancelled_refunded? || event_registration.cancelled_refund_pending?
      'red'
    else
      'orange'
    end

  end

  def event_registration_change_color_class(payment_refund)

    if payment_refund.request_cancelled?
      'red'
    elsif payment_refund.refunded? || payment_refund.requested?
      'blue'
    end
  end

  def is_eligible_to_download_invoice_receipt?(event_registration = nil)
    event_registration.present? && event_registration.event.sy_event_company_id.present? && event_registration.invoice_number.present? && event_registration.sy_event_company_id.present? && event_registration.attachments.last.present? && event_registration.attachments.last.s3_url.present?
  end

  def invoice_receipt_download_error_text(event_registration = nil)

    return 'Company is not associated with event.' unless event_registration.event.sy_event_company_id.present?

    return 'Please provide event registration detail.' unless event_registration.present?

    return 'Invoice not found.' unless event_registration.invoice_number.present?

    return 'Invoice not found.' unless event_registration.attachments.last.present?

  end

  def event_order_status_color_class(event_order)

    if event_order.success? || event_order.approve?
      'green'
    elsif event_order.pending? || event_order.failure? || event_order.rejected?
      'red'
    elsif event_order.dd_received_by_rc? || event_order.dd_received_by_ashram? || event_order.dd_received_by_india_admin?
      'yellow'
    end

  end


  def payment_refund_details(payment_refund)

    return {} unless payment_refund.present?

    {requester_name: payment_refund.try(:requester_user).try(:sadhak_profile).try(:full_name).to_s, responder_name: payment_refund.try(:responder_user).try(:sadhak_profile).try(:full_name).to_s, refunded_amount: ('%.2f' % payment_refund.amount_refunded.to_f), reg_ref_number: payment_refund.event_order.try(:reg_ref_number), request_type: payment_refund.action.try(:titleize), status: payment_refund.status.try(:titleize), max_refundable_amount: ('%.2f' % payment_refund.max_refundable_amount.to_f), cancellation_charges: ('%.2f' % payment_refund.cancellation_charges.to_f), refundable_amount_if_policy_applied: ('%.2f' % payment_refund.policy_refundable_amount.to_f), created_at: payment_refund.created_at.try(:strftime, '%b %d, %Y - %I:%M:%S %p')}

  end


  def payment_refund_line_items_details(payment_refund)

    return [] unless payment_refund.present?

    new_item_statuses = PaymentRefundLineItem.old_item_statuses.invert

    payment_refund.payment_refund_line_items.collect do |payment_refund_line_item|

      d = {full_name: payment_refund_line_item.try(:registered_sadhak_profile).try(:full_name), syid: payment_refund_line_item.try(:registered_sadhak_profile).try(:syid), request_type: new_item_statuses[payment_refund_line_item.new_item_status].try(:titleize).to_s}

      case payment_refund_line_item.new_item_status
      when EventRegistration.statuses["shivir_change_requested"]
        d.merge!({new_shivir_name: payment_refund_line_item.try(:event).try(:event_name_with_location)})
      when EventRegistration.statuses["downgrade_requested"], EventRegistration.statuses["upgrade_requested"]
        d.merge!({new_category_name: payment_refund_line_item.try(:event_seating_category_association).try(:category_name)})
      when EventRegistration.statuses["name_change_requested"]
        d.merge!({new_sadhak_name: "#{payment_refund_line_item.try(:sadhak_profile).try(:syid)}-#{payment_refund_line_item.try(:sadhak_profile).try(:full_name)}"})
      end

      d.merge!({status: payment_refund_line_item.status.try(:titleize), created_at: payment_refund_line_item.created_at.try(:strftime, '%b %d, %Y - %I:%M:%S %p')})

    end

  end

  def event_order_status_color_class(event_order)
    if event_order.success? || event_order.approve?
      'green'
    elsif event_order.rejected? || event_order.failure?
      'red'
    else
      'orange'
    end
  end

  def encryped_payment_details(options = {})
    options.to_json.encrypt if options.present?
  end

end
