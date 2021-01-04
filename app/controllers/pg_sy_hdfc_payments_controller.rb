class PgSyHdfcPaymentsController < ApplicationController

    before_action :authenticate_user!, :except => [:redirect, :paid]
    skip_before_action :verify_authenticity_token, :only => [:redirect, :paid]

    def redirect
        begin

            url_expire_after = 300

            # Getting order id and token
            payment_params = params.slice(:token, :order_id)

            # Validating some checks
            raise SyException, "PgSyHdfcPaymentsController: direct: Token is missing." unless payment_params[:token].present?
            raise SyException, "PgSyHdfcPaymentsController: direct: Order id is missing." unless payment_params[:order_id].present?

            payment = PgSyHdfcPayment.find_by_m_payment_id(payment_params[:order_id])
            hdfc_config = payment.try(:hdfc_config)

            raise SyException, "PgSyHdfcPaymentsController: direct: Ccavenue configuration not found." unless hdfc_config.present?

            event_order = payment.try(:event_order)

            raise SyException, "PgSyHdfcPaymentsController: direct: Event order not found." unless event_order.present?

            # Decrypting token value
            crypto = Crypto.new

            token = crypto.try(:decrypt, payment_params[:token], hdfc_config.working_key)

            raise SyException, "PgSyHdfcPaymentsController: direct: There is some error in decryption of token." unless token.present?

            # Logic to check a valid time stamp niside token
            time_diff = Time.now.to_i - token.to_i

            raise SyException, "PgSyHdfcPaymentsController: direct: Payment token has been expired.\nToken issue at: #{Time.at(token.to_i)}\nToken used at: #{Time.now}\nAllowed time difference is #{url_expire_after} seconds.\nTime difference is: #{time_diff}" if time_diff > url_expire_after

            raise SyException, "PgSyHdfcPaymentsController: direct: Redirect URL not found inside event_order." unless event_order.gateway_redirect_url.present?

            raise SyException, "PgSyHdfcPaymentsController: direct: Payment URL is already used." if event_order.gateway_redirect_url.include?("&used=true")

            url = event_order.gateway_redirect_url

            event_order.update_columns(gateway_redirect_url: "#{event_order.gateway_redirect_url}&used=true")

        rescue SyException => e
            logger.info("Manual Exception: #{e.message}")
            is_error = true
        rescue => e
            is_error = true
            logger.info("Runtime Exception: #{e.message}")
            logger.info(e.backtrace.inspect)
            Rollbar.error(e)
        end

        if is_error
            redirect_to event_event_order(event_order.event, event_order), flash[:alert] = e.message
        else
            redirect_to url
        end
    end

    def paid

        event_order, message, status, transaction_log = PgSyHdfcPayment.paid(params)

        status == 'success' ? flash[:success] = 'Payment received successfully.' : flash[:alert] = message

        if status.eql?("tampering")
            redirect_to event_order.sy_club ? register_sy_club_path(event_order.sy_club) : register_event_path(event_order.event)
        elsif status.eql?("success") || status.eql?("failure")
            redirect_to event_order.sy_club ? complete_sy_club_path(event_order) : hdfc_complete_event_order_path(event_order, transaction_log_id: transaction_log.try(:id))
        else
            redirect_to root_path
        end

    end

end
