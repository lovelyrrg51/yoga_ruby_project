class TransferredEventOrder < ApplicationRecord
  @@refund_details = []
  @@refund_errors = Hash['gateway', [], 'global', []]
  @@other_detail = nil
  @@gateways = [
    {
      gateway_type: 'offline',
      payment_method: 'Cash Payment',
      refund_method: 'cash_refund',
      symbol: 'cash',
      model: 'PgCashPaymentTransaction',
      controller: 'PgCashPaymentTransactionsController',
      success: PgCashPaymentTransaction.statuses['approved'],
      transaction_id: 'transaction_number',
      config_model: nil,
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'offline',
      payment_method: 'Demand draft',
      refund_method: 'dd_refund',
      symbol: 'sydd',
      model: 'PgSyddTransaction',
      controller: 'PgSyddTransactionsController',
      success: PgSyddTransaction.statuses['approved'],
      transaction_id: 'dd_number',
      config_model: 'pg_sydd_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Stripe Payment',
      refund_method: 'stripe_payment_refund',
      symbol: 'stripe',
      model: 'StripeSubscription',
      controller: 'StripeSubscriptionsController',
      success: StripeSubscription.statuses['success'],
      transaction_id: 'card',
      config_model: 'stripe_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Razorpay Payment',
      refund_method: 'razorpay_refund',
      symbol: 'razorpay',
      model: 'PgSyRazorpayPayment',
      controller: 'PgSyRazorpayPaymentsController',
      success: PgSyRazorpayPayment.statuses['success'],
      transaction_id: 'razorpay_payment_id',
      config_model: 'pg_sy_razorpay_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Braintree Payment',
      refund_method: 'braintree_refund',
      symbol: 'braintree',
      model: 'PgSyBraintreePayment',
      controller: 'PgSyBraintreePaymentsController',
      success: PgSyBraintreePayment.statuses['success'],
      transaction_id: 'braintree_payment_id',
      config_model: 'pg_sy_braintree_config',
      validate_payments_method: 'validate_payment_status',
      require_api_payment_status_validation: true
    },
    {
      gateway_type: 'online',
      payment_method: 'Paypal Payment',
      refund_method: 'paypal_direct_payment_refund',
      symbol: 'paypal',
      model: 'PgSyPaypalPayment',
      controller: 'PgSyPaypalPaymentsController',
      success: PgSyPaypalPayment.statuses['success'],
      transaction_id: 'transaction_id',
      config_model: 'pg_sy_paypal_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Ccavenue Payment',
      refund_method: 'ccavenue_refund',
      symbol: 'ccavenue',
      model: 'OrderPaymentInformation',
      controller: 'OrderPaymentInformationsController',
      success: OrderPaymentInformation.statuses['success'],
      transaction_id: 'ccavenue_tracking_id',
      config_model: 'ccavenue_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Hdfc Payment',
      refund_method: 'hdfc_refund',
      symbol: 'hdfc',
      model: 'PgSyHdfcPayment',
      controller: 'PgSyHdfcPaymentsController',
      success: PgSyHdfcPayment.statuses['success'],
      transaction_id: 'hdfc_tracking_id',
      config_model: 'hdfc_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    },
    {
      gateway_type: 'online',
      payment_method: 'Payfast Payment',
      refund_method: 'payfast_refund',
      symbol: 'payfast',
      model: 'PgSyPayfastPayment',
      controller: 'PgSyPayfastPaymentsController',
      success: PgSyPayfastPayment.statuses['success'],
      transaction_id: 'pf_payment_id',
      config_model: 'pg_sy_payfast_config',
      validate_payments_method: nil,
      require_api_payment_status_validation: false
    }]

  def self.refund_details
    @@refund_details
  end

  def self.refund_errors
    @@refund_errors
  end

  def self.reset_globals
    @@refund_details = []
    @@refund_errors = Hash['gateway', [], 'global', []]
    @@other_detail = nil
  end

  def self.gateways
    @@gateways
  end

  def self.other_detail
    @@other_detail
  end

  def self.get_txn_details(event_order_id)
    # Collect all parent ids
    event_order_ids = get_parent_event_order_ids(event_order_id)

    # Collect all event orders
    orders = EventOrder.where(id: event_order_ids)

    # Hold transaction details per event order
    txn_details = []

    # Iterate over each event order ids
    event_order_ids.each_with_index do |eo_id, index|
      total_paid_amount = 0.0

      # Find event order from collection
      order = orders.find{|o| o.id == eo_id.to_i}
      refund_errors.fetch('global').push("Event order not found with id: #{eo_id}.") unless order.present?

      # Create hash holding all details for this event order
      detail = {event_order_id: eo_id, parent_event_order_id: event_order_ids[index+1], payment_method: order.try(:payment_method)}

      # Use above gateways list to get all transactions related to this event order
      gateways.each do |gateway|
        transactions = get_txns(eo_id, gateway[:model], gateway[:success])
        total_paid_amount += transactions.collect{|txn| txn[:amount].to_f}.sum.to_f
        detail[gateway[:symbol].to_sym] = transactions
      end

      # Push needed details to transaction details
      detail[:total_paid_amount] = total_paid_amount
      txn_details.push(detail)
    end
    txn_details
  end

  def self.get_txns(event_order_id, model, status)
    (Object.const_get model).where(event_order_id: event_order_id, status: status).where('amount > ?', 0.0)
  end

  def self.get_parent_event_order_ids(transferred_event_order_id)
    @parent_event_order_ids = [transferred_event_order_id]
    transferred_event_order = self.find_by(child_event_order_id: transferred_event_order_id)
    until transferred_event_order.nil? do
      transferred_event_order_id = transferred_event_order.parent_event_order_id
      @parent_event_order_ids.push(transferred_event_order_id)
      transferred_event_order = self.find_by(child_event_order_id: transferred_event_order_id)
    end
    @parent_event_order_ids
  end

  def self.process_refund(txn_details, requested_refund_amount, refund_other_details)
    # Initially reset globals
    reset_globals

    # Hold other details that will be used in transaction log.
    @@other_detail = refund_other_details

    # Push error if txn details are empty
    refund_errors.fetch('global').push('Transaction details not found.') if txn_details.empty?

    # Iterate over all transaction details for refund
    txn_details.each do |t|
      # Next if total paid amount in this event order is zero. i.e trnasferred event order cases
      next if t[:total_paid_amount] == 0.0

      # Break if requested amount successfully refunded or some gateway error occured.
      break if requested_refund_amount <= 0.0 or refund_errors.fetch('gateway').count > 0

      # Find gateway using payment method
      gateway = gateways.find {|g| g[:payment_method].to_s == t[:payment_method].to_s}

      # Refund the amount
      requested_refund_amount = do_refund(requested_refund_amount, t[gateway[:symbol].to_sym], gateway)

      # Hence payment is paid by multiple gateways
      if requested_refund_amount > 0 and (t[:total_paid_amount] - requested_refund_amount) > 0 and refund_errors.fetch('gateway').count == 0
        # Select gateways where transaction count > 0
        rest_gateways = gateways.select {|g| g != gateway and t[g[:symbol].to_sym].count > 0}

        # Make the rest refunds
        rest_gateways.each do |g|
          break if requested_refund_amount <= 0.0 or refund_errors.fetch('gateway').count > 0
          requested_refund_amount = do_refund(requested_refund_amount, t[g[:symbol].to_sym], g)
        end
      end
    end

    # Returned object
    return {
      db_refunded_amount: db_refunded_amount,
      refunds: refund_details
    }
  end

  def self.do_refund(amount, transactions, gateway)
    req_refund = amount
    unless transactions.empty?
      config_id = get_gateway_config_id(transactions.last[:event_order_id], gateway[:config_model]) if gateway[:gateway_type] == 'online'
      if gateway[:require_api_payment_status_validation]
        unless (Object.const_get gateway[:model].to_s).new.send(gateway[:validate_payments_method].to_s.to_sym, transactions.pluck(gateway[:transaction_id].to_sym), config_id)
          refund_errors.fetch('gateway').push("#{gateway[:payment_method]} has not been settled. Please wait atleast one day...!!")
        end
      end
      transactions.each do |txn|
        refunded_amount = 0.0
        db_remain_amount = 0.0
        db_original_amount = txn[:amount].to_f
        if req_refund <= 0.0 or refund_errors.fetch('gateway').count > 0
          break
        elsif req_refund >= db_original_amount
          db_remain_amount = 0.0
        elsif req_refund < db_original_amount
          db_remain_amount = db_original_amount - req_refund
          txn[:amount] = req_refund
        end
        # Transaction Log
        transaction_log = TransactionLog.create(transaction_loggable_id: txn[:event_order_id], transaction_loggable_type: 'EventOrder', other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:refund], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])
        if gateway[:gateway_type] == 'online'
          payment_refund, message = (Object.const_get gateway[:model].to_s).send(gateway[:refund_method].to_s.to_sym, txn, config_id, transaction_log)
        else
          message = nil
        end
        if !message.present?
          refunded_amount = gateway[:gateway_type] == 'online' ? payment_refund[:amount].to_f : txn[:amount].to_f
          req_refund -= refunded_amount
          h = create_deduct_hash(refunded_amount, db_remain_amount, db_original_amount, txn[:event_order_id], gateway[:payment_method].to_s, txn[:id], gateway[:model].to_s)
          if gateway[:gateway_type] == 'offline'
            payment_refund = (Object.const_get gateway[:model].to_s).find(txn[:id])
            transaction_log.update_attributes(gateway_request_object: txn.as_json, gateway_response_object: payment_refund.as_json, gateway_transaction_id: payment_refund[gateway[:transaction_id].to_sym], status: 'success')
          end
          h[:txn_refund_object] = payment_refund
          refund_details.push(h)
        else
          refund_errors.fetch('gateway').push(message)
        end
      end
    end
    req_refund
  end

  def self.create_deduct_hash(refunded_amount, db_remain_amount, db_original_amount, event_order_id, payment_method, id, model)
    h = Hash.new
    h[:refunded_amount] = refunded_amount.rnd
    h[:remaining_amount] = db_remain_amount.rnd
    h[:original_amount] = db_original_amount.rnd
    h[:event_order_id] = event_order_id
    h[:payment_method] = payment_method
    (Object.const_get model).find(id.to_i).update_attribute('amount', db_remain_amount.to_f)
    h
  end

  def self.db_refunded_amount
    refund_details.collect{|s| s[:refunded_amount].rnd}.sum
  end

  def self.get_refund_errors
    refund_errors.fetch('gateway') + refund_errors.fetch('global')
  end

  def self.seating_category_cancellation_charges(sadhak_profiles)
    EventRegistration.includes(:event_seating_category_association).where(event_order_line_item_id: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}).collect{|r| ((r.event_seating_category_association.try(:price).rnd * r.event_seating_category_association.try(:cancellation_charge).rnd)/100).rnd}.sum
  end

  # Method depricated and moved to check_downgrade method
  def self.is_transfer?(sadhak_profiles)
    new_event_ids = EventSeatingCategoryAssociation.where(id: sadhak_profiles.collect{|sp| sp[:event_seating_category_association_id]}).pluck(:event_id).uniq

    raise SyException, "All new seating category should be belong to same event: #{new_event_ids}" if new_event_ids.count > 1

    old_event_ids = EventRegistration.where(event_order_line_item_id: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}).pluck(:event_id).uniqcloned_sp[:syid] = item.try(:sadhak_profile_id)

    raise SyException, "All old seating category should be belong to same event: #{new_event_ids}" if old_event_ids.count > 1

    new_event_ids.last != old_event_ids.last
  end

  def self.get_gateway_config_id(event_order_id, relation_name)
    payment_gateway_type = PaymentGatewayType.find_by_relation_name(relation_name)
    EventOrder.includes({event: [{payment_gateways: [:pg_sydd_config, :ccavenue_config, :stripe_config, :pg_sy_razorpay_config, :pg_sy_braintree_config, :pg_sy_paypal_config]}]}).find_by_id(event_order_id).try(:event).try(:payment_gateways).try(:send, :find_by_payment_gateway_type_id, payment_gateway_type.try(:id)).try(:send, relation_name).try(:id)
  end
end
