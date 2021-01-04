module PaymentGatewayFormsHelper
  include ApplicationHelper
  include EventOrdersHelper
  include EventsHelper

  # generate data to show in payment page for event order
  def ui_payment_data(event_order = nil, event = nil, upgrade = nil, before_event_order_line_items = nil, sadhak_details_hash = nil, parent_event_order_id = nil)
    currency = event.currency_code
    payment_summary = registration_payment_summary(event_order.event_order_line_items)
    amount = payment_summary&.total_payable_amount.rnd
    event_gateways = event_online_payment_gatways(event)
    event_gateways += event_offline_payment_gateways(event)
    is_india_event = event.country_id == 113
    gateways = {}
    event_order_id = event_order.id
    event_gateways.each_with_index do |ga, index|
      gateway = ga[:gateway_association]&.payment_gateway
      method = ga[:gateway_name]
      case method
      when 'stripe'
        gateways[method] = stripe_form(gateway, amount, event_order_id)
      when 'ccavenue'
        gateways[method] = ccavenue_form(gateway, amount, event_order_id)
      when 'hdfc'
        gateways[method] = hdfc_form(gateway, amount, event_order_id)
      when 'cash'
        gateways[method] = cash_form(gateway, amount, event_order_id)
      when 'sydd'
        gateways[method] = sydd_form(gateway, amount, event_order_id)
      else
        raise SyException, "Payment Method Error"
      end

      # gateway charge fee
      gateways[method][:fee] = {
        percent: gateway.try(gateway&.payment_gateway_type&.relation_name).try(:tax_amount),
        amount: gateway_charges(gateway, amount).rnd
      }
    end

    {
        currency: currency,
        summary: payment_summary,
        event_order_id: event_order_id,
        gateways: gateways,
        is_india_event: is_india_event,
        payment_date: Date.today.to_s,
        upgrade: upgrade.present?,
        parent_event_order_id: parent_event_order_id,
        event_order_line_item_ids: {
            enc_key: EVENT_ORDER_LINE_ITEM_IDS.encrypt,
            enc_val: before_event_order_line_items.to_json.encrypt
        },
        sadhak_profile_details: {
            enc_key: SADHAK_PROFILE_DETAILS.encrypt,
            enc_val: sadhak_details_hash.to_json.encrypt
        }
    }
  end

  def stripe_form(gateway, amount, event_order_id, upgrade = nil, parent_event_order_id = nil)
    config = gateway.try(gateway&.payment_gateway_type&.relation_name)
    r_amount = amount + gateway_charges(gateway, amount).rnd
    gateway_mode_assoc_id = ''
    form_data = {
        amount: r_amount,
        config_id: config&.id.to_s,
        payment_gateway_mode_association_id: gateway_mode_assoc_id,
        enc_key: ENCRYPT_PAYMENT_DETAILS_KEY.encrypt,
        enc_val:
            {
                amount: (amount + gateway_charges(gateway, amount).rnd),
                event_order_id: event_order_id,
                config_id: config&.id.to_s,
                method: 'stripe',
                payment_date: Date.today.to_s,
                payment_gateway_mode_association_id: gateway_mode_assoc_id,
                upgrade: upgrade.present?,
                parent_event_order_id: ''
            }.to_json.encrypt
    }
    form_data[:publishable_key] = config&.publishable_key
    form_data
  end

  def ccavenue_form(gateway, amount, event_order_id, upgrade = nil, parent_event_order_id = nil)
    config = gateway.try(gateway&.payment_gateway_type&.relation_name)
    if (gateway.payment_gateway_mode_associations.count == 1) then
      r_amount = amount + gateway.payment_gateway_mode_associations.last.total_payable_amount(amount)[:total_transaction_charges].rnd
      gateway_mode_assoc_id = gateway.payment_gateway_mode_associations.last.try(:id)
    else
      r_amount = amount + gateway_charges(gateway, amount).rnd
      gateway_mode_assoc_id = ''
    end

    form_data = {
        amount: r_amount,
        config_id: config&.id.to_s,
        payment_gateway_mode_association_id: gateway_mode_assoc_id,
        enc_key: ENCRYPT_PAYMENT_DETAILS_KEY.encrypt,
        enc_val: {
            amount: r_amount,
            event_order_id: event_order_id,
            config_id: config&.id.to_s,
            method: 'ccavenue',
            payment_date: Date.today.to_s,
            payment_gateway_mode_association_id: gateway_mode_assoc_id,
            upgrade: upgrade.present?,
            parent_event_order_id: parent_event_order_id.to_s
        }.to_json.encrypt
    }
  end

  def hdfc_form(gateway, amount, event_order_id, upgrade = nil, parent_event_order_id = nil)
    config = gateway.try(gateway&.payment_gateway_type&.relation_name)
    r_amount = amount + gateway_charges(gateway, amount).rnd
    gateway_mode_assoc_id = ''

    form_data = {
        amount: r_amount,
        config_id: config&.id.to_s,
        payment_gateway_mode_association_id: gateway_mode_assoc_id,
        enc_key: ENCRYPT_PAYMENT_DETAILS_KEY.encrypt,
        enc_val: {
            amount: r_amount,
            event_order_id: event_order_id,
            config_id: config&.id.to_s,
            method: 'hdfc',
            payment_date: Date.today.to_s,
            payment_gateway_mode_association_id: gateway_mode_assoc_id,
            upgrade: upgrade.present?,
            parent_event_order_id: parent_event_order_id.to_s
        }.to_json.encrypt
    }
  end

  def cash_form(gateway, amount, event_order_id, upgrade = nil, parent_event_order_id = nil)
    config = gateway.try(gateway&.payment_gateway_type&.relation_name)
    r_amount = amount + gateway_charges(gateway, amount).rnd
    gateway_mode_assoc_id = ''

    form_data = {
        amount: r_amount,
        config_id: config&.id.to_s,
        payment_gateway_mode_association_id: gateway_mode_assoc_id,
        enc_key: ENCRYPT_PAYMENT_DETAILS_KEY.encrypt,
        enc_val: {
            amount: r_amount,
            event_order_id: event_order_id,
            config_id: config&.id.to_s,
            method: 'cash',
            payment_date: Date.today.to_s,
            upgrade: upgrade.present?,
            parent_event_order_id: parent_event_order_id.to_s
        }.to_json.encrypt
    }
  end

  def sydd_form(gateway, amount, event_order_id, upgrade = nil, parent_event_order_id = nil)
    config = gateway.try(gateway&.payment_gateway_type&.relation_name)
    r_amount = amount + gateway_charges(gateway, amount).rnd
    gateway_mode_assoc_id = ''

    form_data = {
        amount: r_amount,
        config_id: config&.id.to_s,
        payment_gateway_mode_association_id: gateway_mode_assoc_id,
        enc_key: ENCRYPT_PAYMENT_DETAILS_KEY.encrypt,
        enc_val: {
            amount: r_amount,
            event_order_id: event_order_id,
            config_id: config&.id.to_s,
            method: gateway&.payment_gateway_type&.name,
            payment_date: Date.today.to_s,
            upgrade: upgrade.present?,
            parent_event_order_id: parent_event_order_id.to_s
        }.to_json.encrypt
    }
  end
end