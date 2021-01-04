class PgSyHdfcPayment < ApplicationRecord

  enum status: [:pending, :success, :failure]

  belongs_to :user, optional: true
  belongs_to :event_order
  belongs_to :hdfc_config, class_name: 'HdfcConfig', foreign_key: 'config_id'

  validates :billing_name, :billing_address, :billing_address_state, :billing_address_country, :billing_phone, :billing_email, :billing_address_postal_code, presence: true
  validates_format_of :billing_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates :event_order_id , presence: true
  validates :billing_phone, numericality: true

    def self.create_hdfc_payment(payment_detail_params, transaction_log)
        hdfc_base_transaction_url = ENV['ENVIRONMENT'] == 'production' ? 'https://secure.ccavenue.com/transaction/transaction.do' : 'https://test.ccavenue.com/transaction/transaction.do'

        # Raise error if there is no transaction log
        raise "There is some error in creating transaction log." unless (transaction_log.present? || transaction_log.errors.empty?)

        # Find HDFC configuration details
        hdfc_config = HdfcConfig.find_by_id(payment_detail_params[:config_id])
        raise "cannot determine HDFC configration with config id: #{payment_detail_params[:config_id]}." unless hdfc_config.present?

        # Create a pending HDFC payment in order to generate hdfc_order_id
        payment = self.new(payment_detail_params.slice(:amount, :billing_name, :billing_address_city, :billing_address_postal_code, :billing_address_country, :billing_phone, :billing_email, :billing_address_state, :billing_address, :event_order_id, :config_id, :sy_club_id))
        raise payment.errors.full_messages.first unless payment.save

        hdfc_order_id =  "#{payment.event_order.event_id.to_s}-#{payment.event_order.reg_ref_number.to_s}-#{payment.id.to_s}-#{payment.created_at.strftime("%m%d%Y")}"

        payment.update_columns(m_payment_id: hdfc_order_id)

        transaction_log.update_columns(sy_pg_id: payment.id)

        hdfc_params = {
          config_id: payment_detail_params[:config_id],
          merchant_id: hdfc_config.merchant_id.to_s,
          order_id: hdfc_order_id,
          currency: 'INR',
          redirect_url: payment_detail_params[:redirect_url],
          cancel_url: payment_detail_params[:cancel_url],
          language: 'EN',
          amount: payment_detail_params[:amount],
          billing_name: payment_detail_params[:billing_name],
          delivery_name: payment_detail_params[:billing_name],
          billing_address: payment_detail_params[:billing_address],
          delivery_address: payment_detail_params[:billing_address],
          billing_city: payment_detail_params[:billing_address_city],
          delivery_city: payment_detail_params[:billing_address_city],
          billing_state: payment_detail_params[:billing_address_state],
          delivery_state: payment_detail_params[:billing_address_state],
          billing_zip: payment_detail_params[:billing_address_postal_code],
          delivery_zip: payment_detail_params[:billing_address_postal_code],
          billing_country: payment_detail_params[:billing_address_country],
          delivery_country: payment_detail_params[:billing_address_country],
          billing_tel: payment_detail_params[:billing_phone],
          delivery_tel: payment_detail_params[:billing_phone],
          billing_email: payment_detail_params[:billing_email],
          delivery_email: payment_detail_params[:billing_email],
          transaction_log_id: transaction_log.id
        }

        metadata = compute_metadata(transaction_log)

        # To add parameter in HDFC for future use in callbacks
        metadata.each_with_index do |(k,v),index|
          hdfc_params["merchant_param#{index+1}".to_sym] = v.to_s
        end

        crypto = Crypto.new
        encrypted_data = crypto.encrypt(URI.encode_www_form(hdfc_params), hdfc_config.working_key)

        hdfc_params = {
            command: 'initiateTransaction',
            encRequest: encrypted_data,
            access_code: hdfc_config.access_code
        }

        hdfc_redirect_url = hdfc_base_transaction_url + '?' + URI.encode_www_form(hdfc_params)

        payment.event_order.update_columns(gateway_redirect_url: hdfc_redirect_url)

        # Encryption process
        token = Time.now.to_i.to_s

        encrypted_data = crypto.encrypt(token, hdfc_config.working_key)

        # Logic to generate encrypted redirect url for UI
        {order_id: hdfc_order_id, token: encrypted_data}

    end

    def self.compute_metadata(transaction_log)
        other_detail = transaction_log.other_detail.deep_symbolize_keys
        event_order = EventOrder.find_by_id(other_detail[:event_order_id])
        descriptor = "ShivYog"+"-"+event_order.event_id.to_s+"-"+event_order.reg_ref_number
        metadata = {email: other_detail[:guest_email].to_s, descriptor: descriptor, transaction_log_id: transaction_log.id}
        sadhak_profile_ids = other_detail[:sadhak_profile_ids].present? ? other_detail[:sadhak_profile_ids] : other_detail[:sadhak_profiles]
        sadhak_profile_ids = sadhak_profile_ids.join(",")
        if sadhak_profile_ids.length > 500
          last_occurance = sadhak_profile_ids[0..500].rindex(",")
          metadata[:sadhak_profile_ids] = sadhak_profile_ids[0..last_occurance-1]
          metadata[:is_truncated] = true
        else
          metadata[:sadhak_profile_ids] = sadhak_profile_ids
          metadata[:is_truncated] = false
        end
        metadata
    end

    def self.paid(hdfc_params)

      begin

        event_id, reg_ref_number, pg_sy_hdfc_payment_id = hdfc_params[:orderNo].split('-')

        @pg_sy_hdfc_payment = PgSyHdfcPayment.find(pg_sy_hdfc_payment_id)

        hdfc_config = @pg_sy_hdfc_payment.hdfc_config

        crypto = Crypto.new

        decrypted_response = crypto.decrypt(hdfc_params[:encResp], hdfc_config.working_key)

        decrypted_response = ActiveSupport::HashWithIndifferentAccess.new(URI.decode_www_form(decrypted_response).to_h)

        transaction_log_id = decrypted_response[:merchant_param3]

        transaction_log = TransactionLog.find_by_id(transaction_log_id)

        @pg_sy_hdfc_payment = PgSyHdfcPayment.find(pg_sy_hdfc_payment_id)

        @event_order = @pg_sy_hdfc_payment.event_order || EventOrder.find_by_reg_ref_number(reg_ref_number)

        if is_request_tampered(decrypted_response)

          @status = "tampering"
          @message = "Something went wrong with your request. Please contact Ashram."
          logger.info("Runtime Exception In PgSyHdfcPayment: Tampering: #{hdfc_params}")

        else

          if event_id.present? and not @pg_sy_hdfc_payment.success?

            @pg_sy_hdfc_payment.hdfc_tracking_id = decrypted_response[:tracking_id]

            @pg_sy_hdfc_payment.hdfc_payment_mode = decrypted_response[:payment_mode]

            @pg_sy_hdfc_payment.hdfc_status_identifier = decrypted_response[:status_message]

            payment_detail_params = transaction_log.try(:request_params).try(:deep_symbolize_keys)

            if decrypted_response[:order_status].downcase == 'success'

              @event_order.update_attributes(status: 1, transaction_id: decrypted_response[:tracking_id], payment_method: 'Hdfc Payment')

              begin

                @event_order.perform_updation(payment_detail_params[:details])

              rescue => e
                Rollbar.error(e)
              end

              @status = 'success'

            else

              @event_order.update_attributes(status: 'failure', transaction_id: decrypted_response['tracking_id'], payment_method: 'Hdfc Payment') unless @event_order.success?

              @status = 'failure'

              @event_order.notify_sadhak_about_payment_failure((payment_detail_params[:sadhak_profiles] || []).collect{|s| s[:event_order_line_item_id]})

            end

            # to assign status of order payment info
            @pg_sy_hdfc_payment.status = @status

            # To update the transaction log
            transaction_log.update_attributes(gateway_response_object: decrypted_response, gateway_transaction_id: decrypted_response["tracking_id"], status: @pg_sy_hdfc_payment.status) if transaction_log.present?

            @event_order.reload.notify_joining if @pg_sy_hdfc_payment.save and @pg_sy_hdfc_payment.success? and @event_order.present? and @event_order.try(:event).try(:notification_service)

          end

          @status ||= @pg_sy_hdfc_payment.success? ? 'success' : 'failure'

          @message = decrypted_response[:failure_message].present? ? decrypted_response[:failure_message] : decrypted_response[:status_message]

        end

      rescue => e
        logger.info("Runtime Exception In PgSyHdfcPayment: #{e.message}")
        logger.info("Runtime Exception In PgSyHdfcPayment: params: #{hdfc_params}")
        logger.info(e.backtrace.inspect)
        @message = "Something Went Wrong"
        @status = nil
        Rollbar.error(e)
      ensure
        return @event_order, @message, @status, transaction_log
      end
    end

    def self.is_request_tampered(decrypted_response)
      !decrypted_response[:order_id].eql?(@pg_sy_hdfc_payment.m_payment_id) || decrypted_response[:tracking_id].eql?(@pg_sy_hdfc_payment.hdfc_tracking_id)
    end

    def self.hdfc_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      Rails.logger.info("PgSyHdfcPaymentsController: hdfc_refund, Start")
      begin
        raise SyException, "Refund parameters missing - Ccavenue." unless refund_params.present?
        raise SyException, "Transaction log not found - Ccavenue." unless transaction_log.present?
        gateway_request_object = PgSyHdfcPayment.find_by_id(refund_params[:id]).as_json
        refund_info = refund_params.as_json
        Rails.logger.info("PgSyHdfcPaymentsController: hdfc_refund, gateway_request_object: #{gateway_request_object}")
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end
      if message.present?
        transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: message)
      else
        transaction_log.update_attributes(gateway_request_object: gateway_request_object, gateway_response_object: refund_info, gateway_transaction_id: refund_info[:id], status: 'success')
      end
      Rails.logger.info("PgSyHdfcPaymentsController: hdfc_refund, refund_info: #{refund_info}")
      Rails.logger.info("PgSyHdfcPaymentsController: hdfc_refund, message: #{message}")
      Rails.logger.info("PgSyHdfcPaymentsController: hdfc_refund, End")
      return refund_params, message
    end

end
