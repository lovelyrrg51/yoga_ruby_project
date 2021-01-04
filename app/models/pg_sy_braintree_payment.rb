class PgSyBraintreePayment < ApplicationRecord
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

    def create_braintree_payment(pg_sy_braintree_payment_params, transaction_log)
      begin

        logger.info("PgSyBraintreePaymentsController: create:\npg_sy_braintree_payment_params: #{pg_sy_braintree_payment_params}")

        raise SyException, "Braintree: Please input a valid amount." unless pg_sy_braintree_payment_params[:amount].present?

        raise SyException, "Braintree: Please input a valid payment nonce." unless pg_sy_braintree_payment_params[:payment_method_nonce].present?

        raise SyException, "Braintree configuration id missing." unless pg_sy_braintree_payment_params[:config_id].present?

        payment = PgSyBraintreePayment.new(amount: pg_sy_braintree_payment_params[:amount], event_order_id: pg_sy_braintree_payment_params[:event_order_id], sy_club_id: pg_sy_braintree_payment_params[:sy_club_id], config_id: pg_sy_braintree_payment_params[:config_id])

        raise SyException, payment.errors.full_messages.first unless payment.save

        # Collect infomation
        nonce_from_client = pg_sy_braintree_payment_params[:payment_method_nonce]
        amount = pg_sy_braintree_payment_params[:amount]
        config_id = pg_sy_braintree_payment_params[:config_id]
        event_order = payment.event_order

        # Generate descriptor and unique payment id
        if event_order.present?
          unique_payment_id = "#{event_order.try(:event_id).to_s}-#{event_order.try(:reg_ref_number)}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        elsif
          unique_payment_id = "#{pg_sy_braintree_payment_params[:sy_club_id].to_s}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        end

        raise SyException, "Something went wrong while configuring braintree." unless PgSyBraintreeConfig.configure(config_id)

        begin
          gateway_request_object = {
            amount: amount.rnd,
            payment_method_nonce: nonce_from_client.to_s,
            order_id: unique_payment_id,
            options: {
              submit_for_settlement: true
            }
          }
          result = Braintree::Transaction.sale(gateway_request_object)
        rescue Braintree::BraintreeError => e
          message = e.message
        end
        if message.nil?
          if result.success?
            status = 'success'
          elsif result.transaction
              if ['authorization_expired', 'failed', 'gateway_rejected', 'processor_declined', 'voided'].include?(result.transaction.status.to_s)
                status = 'failure'
              else
                status = 'pending'
              end
          else
            message = result.errors.collect{|er| er.message}.to_sentence
          end
        end

      rescue SyException => e
        message = e.message
      rescue => e
        message = e.message
        Rollbar.error(e)
      end

      # Update payment model
      if message.nil? and result and result.transaction
        gateway_response_object = parse_braintree_object(result.transaction)
        payment.update_columns(amount: result.transaction.amount.to_f, currency_iso_code: result.transaction.currency_iso_code, braintree_payment_id: result.transaction.id, refund_ids: result.transaction.refund_ids.to_s, refunded_transaction_id: result.transaction.refunded_transaction_id, status: PgSyBraintreePayment.statuses[status])
      end

      # Update transaction log
      transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: gateway_response_object.present? ? gateway_response_object : message, gateway_transaction_id: gateway_response_object.present? ? result.transaction.id : nil, status: status == 'pending' ? 'failure' : status, sy_pg_id: payment.id)

      return payment, message

    end

    def parse_braintree_object(transaction)
      {
        amount: transaction.amount,
        avs_error_response_code: transaction.avs_error_response_code,
        avs_postal_code_response_code: transaction.avs_postal_code_response_code,
        avs_street_address_response_code: transaction.avs_street_address_response_code,
        # billing_details: transaction.billing_details,
        channel: transaction.channel,
        created_at: transaction.created_at,
        # credit_card_details: transaction.credit_card_details,
        currency_iso_code: transaction.currency_iso_code,
        # customer_details: transaction.customer_details,
        cvv_response_code: transaction.cvv_response_code,
        # descriptor: transaction.descriptor,
        # disbursement_details: transaction.disbursement_details,
        discounts: transaction.discounts,
        disputes: transaction.disputes,
        escrow_status: transaction.escrow_status,
        gateway_rejection_reason: transaction.gateway_rejection_reason,
        id: transaction.id,
        merchant_account_id: transaction.merchant_account_id,
        order_id: transaction.order_id,
        payment_instrument_type: transaction.payment_instrument_type,
        processor_authorization_code: transaction.processor_authorization_code,
        processor_response_code: transaction.processor_response_code,
        processor_response_text: transaction.processor_response_text,
        processor_settlement_response_code: transaction.processor_settlement_response_code,
        processor_settlement_response_text: transaction.processor_settlement_response_text,
        purchase_order_number: transaction.purchase_order_number,
        refund_ids: transaction.refund_ids,
        refunded_transaction_id: transaction.refunded_transaction_id,
        risk_data: transaction.risk_data,
        service_fee_amount: transaction.service_fee_amount,
        settlement_batch_id: transaction.settlement_batch_id,
        # shipping_details: transaction.shipping_details,
        status: transaction.status,
        # status_history: transaction.status_history,
        tax_amount: transaction.tax_amount,
        tax_exempt: transaction.tax_exempt,
        type: transaction.type,
        updated_at: transaction.updated_at,
        voice_referral_number: transaction.voice_referral_number
      }
    end

    def braintree_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      if refund_params != nil and config_id != nil and transaction_log != nil
        braintree_refund_params = refund_params
        amount = braintree_refund_params[:amount]
        braintree_payment_id = braintree_refund_params[:braintree_payment_id]
        gateway_request_object = {
          braintree_payment_id: braintree_payment_id,
          amount: amount
        }
        if PgSyBraintreeConfig.configure(config_id)
          begin
            result = Braintree::Transaction.refund(braintree_payment_id.to_s, amount.to_s)
          rescue Braintree::BraintreeError => e
            message = e.message
          end
          if result.success?
            pg_sy_braintree_payment = PgSyBraintreePayment.find_by(braintree_payment_id: braintree_payment_id)
            pg_sy_braintree_payment.update_attributes(refunded_transaction_id: result.transaction.refunded_transaction_id, refund_ids: result.transaction.refund_ids.to_sentence(words_connector:',', two_words_connector: ',', last_word_connector: ',')) if pg_sy_braintree_payment.present?
            refund_info = {
              id: result.transaction.id,
              amount: result.transaction.amount,
              created_at: result.transaction.created_at,
              currency_iso_code: result.transaction.currency_iso_code,
              merchant_account_id: result.transaction.merchant_account_id,
              refund_ids: result.transaction.refund_ids,
              refunded_transaction_id: result.transaction.refunded_transaction_id,
              service_fee_amount: result.transaction.service_fee_amount,
              settlement_batch_id: result.transaction.settlement_batch_id,
              status: result.transaction.status,
              tax_amount: result.transaction.tax_amount,
              type: result.transaction.type,
              updated_at: result.transaction.updated_at
            }
          else
            message = result.errors.collect{|er| er.message}.to_sentence
          end
        else
          message = 'Braintree Configuration error'
        end
        if message.present?
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: message)
          return true, message
        else
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: refund_info, gateway_transaction_id: result.transaction.id, status: 'success')
          return refund_info
        end
      else
        return true, 'Refund parameters missing Braintree'
      end
    end

    def validate_payment_status(transactions = nil, config_id = nil)
      if transactions != nil and config_id != nil and PgSyBraintreeConfig.configure(config_id)
        is_all_settled = true
        transactions.each do |transaction|
          break unless is_all_settled
          begin
            bt_transaction = Braintree::Transaction.find(transaction.to_s)
            is_all_settled = false if bt_transaction.status != 'settled'
          rescue Braintree::BraintreeError
            is_all_settled = false
          end
        end
        is_all_settled
      else
        false
      end
    end

  end
end
