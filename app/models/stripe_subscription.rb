class StripeSubscription < ApplicationRecord
  include AASM

  belongs_to :event_order, optional: true
  belongs_to :sy_club, optional: true

  enum status: { pending: 0, success: 1 }
  aasm column: :status, enum: true do
    state :pending, initial: true
    state :success

    event :approve_details do
      transitions from: :pending, to: :success
    end
  end

  class << self

    def create_payment(stripe_params, transaction_log)
      begin

        # Generate pending charge
        payment = StripeSubscription.new(event_order_id: stripe_params[:event_order_id], card: stripe_params[:stripeToken], amount: stripe_params[:amount], sy_club_id: stripe_params[:sy_club_id], config_id: stripe_params[:config_id])

        raise SyException, payment.errors.full_messages.first unless payment.save

        raise SyException, "Payment configration id is missing." unless stripe_params[:config_id].present?

        raise SyException, "Stripe token is missing." unless stripe_params[:stripeToken].present?

        raise SyException, "Payable amount is missing." unless stripe_params[:amount].present?

        raise SyException, "Guest Email is missing." unless stripe_params[:guest_email].present?

        # Collect needed data
        config_id = stripe_params[:config_id]
        stripe_config = StripeConfig.find(config_id) if config_id.present?
        currency_code = DbCountry.find(stripe_config.country_id).currency_code  if stripe_config.country_id.present?
        currency_code = stripe_params[:pay_in_usd] ? 'usd' : currency_code
        amount = stripe_params[:amount]
        email = stripe_params[:guest_email]

        ## assign statement descriptor value
        event_order = EventOrder.find_by(id: stripe_params[:event_order_id]) if stripe_params[:event_order_id].present?

        # Generate descriptor and unique payment id
        if event_order.present?
          descriptor = "ShivYog"+"-"+event_order.event_id.to_s+"-"+event_order.reg_ref_number
          unique_payment_id = "#{event_order.try(:event_id).to_s}-#{event_order.try(:reg_ref_number)}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        else
          descriptor = "ShivYog"+"-"+stripe_params[:sy_club_id].to_s
          unique_payment_id = "#{stripe_params[:sy_club_id].to_s}-#{payment.try(:id)}-#{transaction_log.try(:id)}-#{payment.try(:created_at).try(:strftime, ("%m/%d/%Y")).to_s.delete('/')}"
        end

        # Configure stripe
        raise SyException, "Something went wrong while configuring stripe." unless StripeConfig.configure(config_id)

        begin
          customer = Stripe::Customer.create(
            email: email.to_s,
            card: stripe_params[:stripeToken]
          )
          metadata = stripe_metadata(transaction_log)
          metadata[:unique_payment_id] = unique_payment_id
          gateway_request_object = {
            :customer    => customer.id,
            :amount      => (amount.to_f * 100).to_i,
            :description => "Shivyog Registration - #{unique_payment_id}",
            :currency    => currency_code.to_s.downcase,
            :metadata    => metadata,
            :statement_descriptor => descriptor
          }
          charge = Stripe::Charge.create(gateway_request_object)
        rescue Stripe::StripeError => e
          message = e.message
          Rails.logger.info(e)
          Rollbar.error(e)
        end

      rescue => e
        message = e.message
        Rollbar.error(e)
      end

      # Update status accordingly
      status = (charge.present? and charge.status == "succeeded") ? 'success' : 'pending'
      gateway_request_object[:unique_payment_id] = unique_payment_id unless gateway_request_object.nil?
      # Update transaction log
      transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: charge.present? ? charge : message, gateway_transaction_id: charge.present? ? charge.id : nil, status: status == 'success' ? status : 'failure', sy_pg_id: payment.id)

      # update payment
      if message.nil? and charge.present?
        amount = charge.amount.to_f/100
        payment.update_columns(amount: amount, description: charge.description, customer_id: customer.id, status: StripeSubscription.statuses[status], charge_id: charge.id)
      end

      return payment, message
    end

    def stripe_metadata(transaction_log)
      other_detail = transaction_log.other_detail.deep_symbolize_keys
      metadata = {transaction_log_id: transaction_log.id.to_s, email: other_detail[:guest_email].to_s, sy_club_id: other_detail[:sy_club_id], event_order_id: other_detail[:event_order_id], event_id: other_detail[:event_id]}
      sadhak_profile_ids = other_detail[:sadhak_profile_ids].present? ? other_detail[:sadhak_profile_ids] : other_detail[:sadhak_profiles]
      sadhak_profile_ids = sadhak_profile_ids.join(";")
      if sadhak_profile_ids.length > 500
        last_occurance = sadhak_profile_ids[0..500].rindex(";")
        metadata[:sadhak_profile_ids] = sadhak_profile_ids[0..last_occurance-1]
        metadata[:is_truncated] = true
      else
        metadata[:sadhak_profile_ids] = sadhak_profile_ids
        metadata[:is_truncated] = false
      end
      metadata
    end

    def stripe_payment_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      if refund_params != nil and config_id != nil and transaction_log != nil
        stripe_refund_params = refund_params
        @amount = stripe_refund_params[:amount]
        @charge = stripe_refund_params[:charge_id]
        @config_id = config_id
        @stripe_subscription = StripeSubscription.where(charge_id: @charge).last
        message = nil
        gateway_request_object = {
          charge: @charge,
          amount: ((@amount.to_f)*100).to_i,
          metadata: {transaction_log_id: transaction_log.id.to_s},
          reason: 'requested_by_customer'
        }
        if StripeConfig.configure(@config_id)
          begin
            ch = Stripe::Charge.retrieve(@charge.to_s)
            refund = ch.refunds.create(
              :amount => ((@amount.to_f)*100).to_i,
              :metadata => {transaction_log_id: transaction_log.id.to_s},
              :reason => 'requested_by_customer'
            )
            rescue Stripe::StripeError => e
              message = e.message
          end
          if refund
            @stripe_subscription.update_attribute("refund_id", refund.id)
            refund.amount = refund.amount.to_f/100
          else
            message = 'Error in stripe refund'
          end
        else
          message = 'Stripe configration not found'
        end
        # Update transaction log according to message value
        if message.present?
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: message)
          return true, message
        else
          transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: refund, gateway_transaction_id: refund.id, status: 'success')
          return refund
        end
      else
        return true, 'Refund parameters missing Stripe'
      end
    end

  end

end
