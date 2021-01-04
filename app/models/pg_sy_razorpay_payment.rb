class PgSyRazorpayPayment < ApplicationRecord
  include AASM

  belongs_to :event_order
  belongs_to :sy_club

  enum status: { pending: 0, success: 1, failure: 2 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :success
    state :failure
  end

  class << self

    def create_razorpay_payment(razorpay_params, transaction_log)

      begin
        # Perform some parameters checking
        raise SyException, "Please provide a config id for razorpay." unless razorpay_params[:config_id].present?
        raise SyException, "Please provide razorpay payment id to capture payment." unless razorpay_params[:razorpay_payment_id].present?

        payment = PgSyRazorpayPayment.new(amount: razorpay_params[:amount], event_order_id: razorpay_params[:event_order_id], sy_club_id: razorpay_params[:sy_club_id], config_id: razorpay_params[:config_id])

        raise SyException, payment.errors.full_messages.first unless payment.save

        # Local variables assigning
        message = nil
        amount = razorpay_params[:amount]
        event_order = payment.event_order
        config_id = razorpay_params[:config_id]
        razorpay_payment_id = razorpay_params[:razorpay_payment_id].to_s

        # Generate descriptor and unique payment id
        if event_order.present?
          unique_payment_id = "#{event_order.try(:event_id).to_s}-#{event_order.try(:reg_ref_number)}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        elsif
          unique_payment_id = "#{razorpay_params[:sy_club_id].to_s}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        end

        # Create gateway request object
        gateway_request_object = {
          razorpay_payment_id: razorpay_payment_id,
          amount: amount
        }

        # Raise error if not able to connect razorypay with provided configuration
        raise SyException, 'Razorpay configuration not found.' unless PgSyRazorpayConfig.configure(config_id)

        # Reterive the payment
        payment_info = Razorpay::Payment.fetch(razorpay_payment_id)

        # Update razorpay request object
        gateway_request_object = gateway_request_object.deep_merge({email: payment_info.email, contact: payment_info.contact, id: payment_info.id, notes: payment_info.notes, created_at: payment_info.created_at, unique_payment_id: unique_payment_id})

        # Compute caputred amount
        amount = (amount.to_f * 100).to_i

        # Raise error if amount is zero
        raise SyException, "Please provide a valid payable amount." if amount == 0

        # Capture the amount
        payment_info = payment_info.capture(amount: amount)

      # Exceptions handlers
      rescue Razorpay::Error => e
        logger.info("Razorpay Error: #{e.code}")
        message = e.code
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end

      # Decision based on message
      if message.nil? and payment_info.present?
        status = payment_info.status == 'captured' ? 'success' : 'pending'
        amount = payment_info.amount.to_f/100
        amount_refunded = payment_info.amount_refunded.to_f/100
        payment.update_columns(razorpay_payment_id: payment_info.id, entity: payment_info.entity, amount: amount, currency: payment_info.currency, description: payment_info.description, refund_status: payment_info.refund_status, amount_refunded: amount_refunded, notes: payment_info.notes.to_s, status: PgSyRazorpayPayment.statuses[status])
      end

      transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: payment_info.present? ? payment_info.as_json["attributes"] : message, gateway_transaction_id: razorpay_payment_id, status: status == 'success' ? status : 'failure', sy_pg_id: payment.id)

      return payment, message

    end

    def razorpay_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      if refund_params != nil and config_id != nil and transaction_log != nil
        razorpay_refund_params = refund_params
        amount = razorpay_refund_params[:amount]
        razorpay_payment_id = razorpay_refund_params[:razorpay_payment_id]
        config_id = config_id
        pg_sy_razorpay_payment = PgSyRazorpayPayment.find_by(razorpay_payment_id: razorpay_payment_id)
        message = nil
        gateway_request_object = {
          razorpay_payment_id: razorpay_payment_id,
          amount: amount
        }
        if PgSyRazorpayConfig.configure(config_id)
          begin
            refund_info = Razorpay::Payment.fetch(razorpay_payment_id).refund({amount: ((amount.to_f)*100).to_i})
            payment_info = Razorpay::Payment.fetch(razorpay_payment_id)
          rescue Razorpay::Error => e
            message = e.code
          end
          amount_refunded = payment_info.amount_refunded.to_f/100
          if refund_info.present? and pg_sy_razorpay_payment.present? and payment_info.present?
            pg_sy_razorpay_payment.update_attributes(refund_id: refund_info.id, refund_status: payment_info.refund_status.to_s, amount_refunded: amount_refunded)
            gateway_response_object = refund_info
            refund_info = {id: refund_info.id, entity: refund_info.entity, amount: refund_info.amount.to_f/100, currency: refund_info.currency, payment_id: refund_info.payment_id, created_at: refund_info.created_at}
          else
            message = 'Error in updating the data'
          end
        else
          message = 'Razorpay Configration not found'
        end
        if message.present?
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: message)
          return true, message
        else
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: gateway_response_object.as_json["attributes"], gateway_transaction_id: gateway_response_object.id, status: 'success')
          return refund_info
        end
      else
        return true, 'Refund parameters missing Razorpay'
      end
    end

  end
end
