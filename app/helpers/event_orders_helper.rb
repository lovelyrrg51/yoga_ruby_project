module EventOrdersHelper
  def registration_payment_summary(event_order_line_items = [])

    discount = 0.0

    total_registration_fee = event_order_line_items.collect{|item| item.category_price.to_f }.reduce(&:+).rnd

    event_order_line_items.each do |item|

      if (item.sadhak_profile.event_ids & (item.event.discount_plan.try(:event_ids)|| [])).present?

        discount += item.event.calculate_discount([{syid: item.sadhak_profile_id.to_s, first_name: item.sadhak_profile.first_name, event_seating_category_association_id: item.event_seating_category_association_id.to_s, event_order_line_item_id: item.id.to_s}])

      end

    end

    service_tax = event_order_line_items.last.event.calculate_tax_amount(original_amount: total_registration_fee, total_discount: discount)[:total_tax_applied].rnd

    total_payable_amount = total_registration_fee + service_tax - discount

    {
        total_registration_fee: total_registration_fee.rnd,
        amount_before_taxes: (total_registration_fee.rnd - discount.rnd),
        service_tax: service_tax.rnd,
        total_payable_amount: total_payable_amount.rnd,
        discount: discount.rnd,
        tax_breakup: event_order_line_items.last.event.calculate_tax_amount(original_amount: total_registration_fee, total_discount: discount)[:tax_breakup]
    }
  end

  def discount_per_sadhak(item)
    if (item.sadhak_profile.event_ids & (item.event.discount_plan.try(:event_ids)|| [])).present?
      item.event.calculate_discount([{syid: item.sadhak_profile_id.to_s, first_name: item.sadhak_profile.first_name, event_seating_category_association_id: item.event_seating_category_association_id.to_s, event_order_line_item_id: item.id.to_s}])
    else
      0.0
    end
  end

  def gateway_charges(gateway, amount)
    gateway_tax_percentage = gateway.try(gateway.try(:payment_gateway_type).try(:relation_name)).try(:tax_amount).to_f
    ((amount.to_f * gateway_tax_percentage).to_f / 100).rnd
  end

  def event_order_selectable_statuses(event = nil)

    options_for_select = EventOrder.statuses.slice(:pending, :success, :failure)

    options_for_select.merge!(EventOrder.statuses.slice(:approve, :rejected)) if event.try(:pre_approval_required?)

    options_for_select.merge!(EventOrder.statuses.slice(:dd_received_by_rc, :dd_received_by_ashram, :dd_received_by_india_admin)) if (event.try(:payment_gateway_types).try(:pluck, :name) || []).include?('sydd')

    options_for_select.collect{|k, v| [k.titleize, v]}

  end

  def event_order_updatable_statuses(event_order = nil)

    if (event_order.pending? || event_order.approve? || event_order.rejected?) && event_order.try(:event).try(:pre_approval_required?)

      options_for_select = EventOrder.statuses.slice(:pending, :approve, :rejected) 

    else

      options_for_select = EventOrder.statuses.slice(event_order.status)

    end

    options_for_select.collect{|k, v| [k.titleize, v]}
    
  end

  def get_reg_payment_summary_object(registration_payment_summary = {})
    registration_payment_summary = registration_payment_summary.with_indifferent_access
    res = {
      total_registration_fee: registration_payment_summary[:total_registration_fee] || registration_payment_summary[:original_amount] || 0.0,
      totol_discount: registration_payment_summary[:total_discount] || registration_payment_summary[:discount] || 0.0,
      tax_breakup: registration_payment_summary[:tax_breakup] || 0.0,
      total_tax_amount: (registration_payment_summary[:tax_breakup] || []).reduce(0.0) {|sum, obj| sum + obj["amount"] || 0.0}
    }
    res[:total_payable_amount] = res[:total_registration_fee] - res[:totol_discount] + res[:total_tax_amount]
    res
  end

end
