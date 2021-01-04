class PgSyPayfastPayment < ApplicationRecord
  include AASM

  default_scope { where(is_deleted: false) }

  enum status: { pending: 1, failed: 2, success: 3 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :failed
    state :success
  end

  belongs_to :event_order
  belongs_to :pg_sy_payfast_config, class_name: 'PgSyPayfastConfig', foreign_key: 'config_id'

  # Create payfast payment
  def self.create_payfast_payment(payment_detail_params, transaction_log)
    # Raise error if there is no transaction log
    raise SyException, "There is some error in creating transaction log." if (not transaction_log.present? or not transaction_log.errors.empty?)

    # Find payfast configuration details
    payfast_config = PgSyPayfastConfig.find_by_id(payment_detail_params[:config_id])
    raise SyException, "cannot determine payfast configration with config id: #{payment_detail_params[:config_id]}." unless payfast_config.present?

    # Add currency code
    payment_detail_params[:currency] = "ZAR"

    # Create a pending payfast payment in order to generate m_payment_id
    payment = self.new(payment_detail_params.slice(:name_first, :name_last, :email_address, :event_order_id, :sy_club_id, :currency, :config_id).merge({amount_gross: payment_detail_params[:amount]}))
    raise SyException, payment.errors.full_messages.first unless payment.save

    # (id: integer, name_first: string, name_last: string, email_address: string, m_payment_id: string, amount: decimal, item_description: string, signature: string, event_order_id: integer, sy_club_id: integer, status: integer, pf_payment_id: string, amount_fee: decimal, amount_net: decimal, currency: string, config_id: integer, is_deleted: boolean, created_at: datetime, updated_at: datetime)

    m_payment_id =  "#{payment.event_order.event_id.to_s}-#{payment.event_order.reg_ref_number.to_s}-#{payment.id.to_s}-#{payment.created_at.strftime("%m/%d/%Y").to_s.delete('/')}"

    payment_detail_params[:item_name] = "Shivyog Registration Order Id: #{m_payment_id.to_s}."

    payment_detail_params[:item_description] = "Shivyog Registration for #{payment.event_order.try(:event).try(:event_name_with_location).to_s} with order id: #{payment_detail_params[:item_name]}."

    return_url = payment_detail_params[:return_url].gsub!('order_id', m_payment_id)
    cancel_url = payment_detail_params[:cancel_url].gsub!('order_id', m_payment_id)
    notify_url = payment_detail_params[:notify_url]

    # Generate a helper using OffsitePayments gem
    pay_fast = OffsitePayments.integration(:pay_fast)
    helper = pay_fast.helper(m_payment_id, payfast_config.merchant_id, payment_detail_params.slice(:amount, :currency).deep_merge({credential2: payfast_config.merchant_key, notify_url: notify_url, return_url: return_url}).deep_symbolize_keys)

    # Add key cancel_url in mappings
    helper.mappings[:cancel_url] = "cancel_url"

    # Add cancel URL to helper
    helper.add_field(:cancel_url, cancel_url)

    # helper.add_field("email_confirmation", 1)
    # helper.add_field("confirmation_address", payment_detail_params[:email_address])

    # Add fields to helper from payment_detail_params
    helper.request_attributes.each do |_attr|
      helper.add_field(_attr.to_s ,payment_detail_params[_attr])
    end

    # Add metadata
    metadata = compute_metadata(transaction_log)
    metadata.each_with_index do |(k,v),index|
      break if index > 4
      helper.add_field("custom_str#{index+1}", v.to_s)
    end

    signature = helper.generate_signature(:request)

    helper.add_field("signature", signature)

    payment.update_columns(m_payment_id: m_payment_id, item_description: payment_detail_params[:item_description], signature: signature)

    payfast_redirect_url = "#{pay_fast.service_url}?#{helper.request_signature_string}"

    logger.info("PgSyPayfastPayment: create_payfast_payment: Payfast Payment URL for m_payment_id: #{m_payment_id}\n#{payfast_redirect_url}\n")

    transaction_log.update_columns(request_params: payment_detail_params, sy_pg_id: payment.id)

    payment.event_order.update_columns(gateway_redirect_url: payfast_redirect_url)

    # Encryption process
    crypto = Crypto.new

    token = Time.now.to_i.to_s

    logger.info("PgSyPayfastPayment: create_payfast_payment: Before encryption token is: #{token}")

    encrypted_data = crypto.encrypt(token, payfast_config.merchant_key)

    logger.info("PgSyPayfastPayment: create_payfast_payment: Encrypted token is: #{encrypted_data}")

    logger.info("PgSyPayfastPayment: create_payfast_payment: Decryted token is: #{crypto.decrypt(encrypted_data, payfast_config.merchant_key)}")

    # Logic to generate encrypted redirect url for UI
    redirect_url = "#{payfast_redirect_url}?order_id=#{m_payment_id}&token=#{encrypted_data}"

    logger.info("PgSyPayfastPayment: create_payfast_payment: Encrypted URL for m_payment_id: #{m_payment_id} is\n#{redirect_url}")

    return redirect_url
  end

  def self.compute_metadata(transaction_log)
    other_detail = transaction_log.other_detail.deep_symbolize_keys
    event_order = EventOrder.find_by_id(other_detail[:event_order_id])
    descriptor = "ShivYog"+"-"+event_order.event_id.to_s+"-"+event_order.reg_ref_number
    metadata = {email: other_detail[:guest_email].to_s, descriptor: descriptor, transaction_log_id: transaction_log.id}
    sadhak_profile_ids = other_detail[:sadhak_profile_ids].present? ? other_detail[:sadhak_profile_ids] : other_detail[:sadhak_profiles]
    sadhak_profile_ids = sadhak_profile_ids.join(";")
    if sadhak_profile_ids.length > 255
      last_occurance = sadhak_profile_ids[0..255].rindex(";")
      metadata[:sadhak_profile_ids] = sadhak_profile_ids[0..last_occurance-1]
      metadata[:is_truncated] = "True"
    else
      metadata[:sadhak_profile_ids] = sadhak_profile_ids
      metadata[:is_truncated] = "False"
    end
    return metadata
  end

  def self.payfast_paid(raw_post)
    is_error = false

    @notification = OffsitePayments.integration(:pay_fast).notification(raw_post)

    logger.info("PgSyPayfastPayment: payfast_paid, notification params for m_payment_id #{@notification.item_id} are: \n#{@notification.params}")

    # Find transaction log
    transaction_log = TransactionLog.find_by_id(@notification.params.custom_str3)

    logger.info("PgSyPayfastPayment: payfast_paid, is transaction_log found for m_payment_id #{@notification.item_id} : #{transaction_log.present?}")

    # Get details that are required to update if payment is successful
    details = (transaction_log.try(:request_params).try(:deep_symbolize_keys) || {})[:details] || []

    # Get pg_sy_payfast_payment for this order
    pg_sy_payfast_payment = PgSyPayfastPayment.includes(:event_order, :pg_sy_payfast_config).find_by_m_payment_id(@notification.item_id)

    logger.info("PgSyPayfastPayment: payfast_paid, is pg_sy_payfast_payment found for m_payment_id #{@notification.item_id}: #{pg_sy_payfast_payment.present?}.")

    # Validate data received from Payfast server
    if @notification.acknowledge
      begin
        # Perform security checks, Validate sender and merchant id
        if @notification.valid_sender?($ip) and pg_sy_payfast_payment.try(:pg_sy_payfast_config).try(:merchant_id) == @notification.merchant_id

          # Validate gross amount
          if pg_sy_payfast_payment.amount_gross.rnd == @notification.gross.rnd

            # Check wether payment is already processed or not
            unless pg_sy_payfast_payment.processed?

              # Handle payment complete/failed case
              if @notification.complete?

                # The net amount credited to the receiver's account.
                pg_sy_payfast_payment.amount = @notification.params['amount_net'].rnd

                # The total in fees which was deducted from the amount.
                pg_sy_payfast_payment.amount_fee = @notification.fee.rnd

                # Assign net amount recieved to account
                pg_sy_payfast_payment.amount_net = @notification.params['amount_net'].rnd

                # Update event order status and transaction id and payment method
                pg_sy_payfast_payment.event_order.update(status: 1, transaction_id: @notification.transaction_id, payment_method: 'Payfast Payment')

                begin
                  # Update event order line items and event registrations as payment completed.
                  pg_sy_payfast_payment.event_order.perform_updation(details) if details.present?

                rescue => e
                  logger.info("PgSyPayfastPayment: payfast_paid, Exception occured while updating tax details and status of line item and event registrations, error: #{e.message}")
                end
              else
                # Update event order status and transaction id and payment method
                pg_sy_payfast_payment.event_order.update(status: 'failure', transaction_id: @notification.transaction_id, payment_method: 'Payfast Payment') unless pg_sy_payfast_payment.event_order.success?

                # Notify all sadhaks about payment failure
                pg_sy_payfast_payment.event_order.notify_sadhak_about_payment_failure((details || []).collect{|d| d[:event_order_line_item_id]})
              end
              pg_sy_payfast_payment.processed = true
              pg_sy_payfast_payment.pf_payment_id = @notification.transaction_id
              pg_sy_payfast_payment.status = @notification.complete? ? "success" : "failed"

              # Save the details
              pg_sy_payfast_payment.save

              # Send success email
              if pg_sy_payfast_payment.success?
                pg_sy_payfast_payment.event_order.reload.notify_joining if pg_sy_payfast_payment.event_order.try(:event).try(:notification_service)
              end

            else
              logger.error("PgSyPayfastPayment: payfast_paid, Payment for m_payment_id: #{@notification.item_id} is already proceed with transaction_id: #{pg_sy_payfast_payment.pf_payment_id}.")
            end
          else
            logger.error("PgSyPayfastPayment: payfast_paid, Payment for m_payment_id: #{@notification.item_id} amount does not match. Notification gross: #{@notification.gross.rnd} and Actual database captured amount: #{pg_sy_payfast_payment.amount_gross.rnd}")
          end
        else
          logger.error("Exception: PgSyPayfastPayment: payfast_paid, Either not a valid sender or merchant_id mismatched for m_payment_id: #{@notification.item_id} error: #{e.message}")
        end
      rescue => e
        logger.error("Exception: PgSyPayfastPayment: payfast_paid, while processing notification for m_payment_id: #{@notification.item_id} error: #{e.message}")
      ensure

        # To update the transaction log
        if transaction_log.present?
          transaction_log.update_columns(gateway_response_object: @notification.params, gateway_transaction_id: @notification.transaction_id, status: pg_sy_payfast_payment.failed? ? "failure" : pg_sy_payfast_payment.status)

          logger.info(transaction_log.inspect)
        else
          logger.error("PgSyPayfastPayment: payfast_paid, TransactionLog not available to update for m_payment_id: #{@notification.item_id}")
        end
      end
    else
      is_error = true
    end
    is_error
  end

  def self.payfast_refund(refund_params = nil, config_id = nil, transaction_log = nil)
    begin
      raise SyException, "Refund parameters missing - payfast." unless refund_params.present?
      raise SyException, "Transaction log not found - payfast." unless transaction_log.present?
      gateway_request_object = PgSyPayfastPayment.find_by_id(refund_params[:id]).as_json
      refund_info = refund_params.as_json
    rescue SyException, StandardError => e
      message = e.message
    end

    if message.present?
      transaction_log.update_attributes(
        gateway_request_object: gateway_request_object,
        gateway_response_object: message
      )
    else
      transaction_log.update_attributes(
        gateway_request_object: gateway_request_object,
        gateway_response_object: refund_info,
        gateway_transaction_id: refund_info[:id],
        status: 'success'
      )
    end

    return refund_params, message
  end
end
