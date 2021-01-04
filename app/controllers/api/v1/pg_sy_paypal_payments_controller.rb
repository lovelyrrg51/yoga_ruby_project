module Api::V1
  class PgSyPaypalPaymentsController < BaseController
    before_action :set_pg_sy_paypal_payment, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, :except => [:paypal_direct_payment_refund, :paypal_direct_payment, :create_paypal_payment, :paypal_express_checkout, :paypal_get_express_checkout_payment, :paypal_do_express_checkout_payment, :paypal_express_checkout_club, :paypal_do_express_checkout_payment_club]
    skip_before_action :verify_authenticity_token, :only => [:paypal_direct_payment_refund, :paypal_direct_payment, :create_paypal_payment, :paypal_express_checkout, :paypal_get_express_checkout_payment, :paypal_do_express_checkout_payment, :paypal_express_checkout_club, :paypal_do_express_checkout_payment_club]
    respond_to :json
  
    require "net/http"
    require "net/https"
    require "uri"
    require 'cgi'
    # GET /pg_sy_paypal_payments
    def index
      @pg_sy_paypal_payments = PgSyPaypalPayment.all
      render json: @pg_sy_paypal_payments
    end
  
    # GET /pg_sy_paypal_payments/1
    def show
    end
  
    # GET /pg_sy_paypal_payments/new
    def new
      @pg_sy_paypal_payment = PgSyPaypalPayment.new
    end
  
    # GET /pg_sy_paypal_payments/1/edit
    def edit
    end
  
    # POST /pg_sy_paypal_payments
    def create
      @pg_sy_paypal_payment = PgSyPaypalPayment.new(pg_sy_paypal_payment_params)
      if @pg_sy_paypal_payment.save
        aa = paypal_test_payment(@pg_sy_paypal_payment)
        render json: @pg_sy_paypal_payment
      else
        render json: @pg_sy_paypal_payment.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sy_paypal_payments/1
    def update
      if @pg_sy_paypal_payment.update
        render json: @pg_sy_paypal_payment
      else
        render json: @pg_sy_paypal_payment.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sy_paypal_payments/1
    def destroy
      pg_py_payment = @pg_sy_paypal_payment.destroy
      render json: pg_py_payment
    end
  
  
    def paypal_direct_payment(paypal_params)
      payment_params = paypal_params
      @order_id = payment_params[:event_order_id]
      # config_id = payment_params[:config_id]
      @paypal_config = PgSyPaypalConfig.where(id: payment_params[:config_id]).last
      # paypal_config = configure_paypal(config_id)
      # return paypal_config
      @hash = {
        USER: @paypal_config.username.to_s, #paypal_config['user'], #
        PWD:@paypal_config.password.to_s, # paypal_config['passowrd'],#
        SIGNATURE: @paypal_config.signature.to_s, #paypal_config['signature'],#
        METHOD: 'DoDirectPayment',
        # IPADDRESS: request.remote_ip,
        VERSION: ENV['PAYPAL_VERSION'],
        # PAYMENTACTION: 'Authorization',
        AMT: (payment_params[:amount].to_f*100).to_i, #50.20,
        ACCT: payment_params[:acct],
        # CREDITCARDTYPE: 'VISA',
        CVV2: payment_params[:cvv2],
        FIRSTNAME: payment_params[:first_name],
        LASTNAME: payment_params[:last_name],
        STREET: payment_params[:street],
        CITY: payment_params[:city],
        STATE: payment_params[:state],
        ZIP: payment_params[:zip],
        COUNTRYCODE: payment_params[:currency_code] == 'USD' ? 'US' : @paypal_config.country_ISO3, #payment_params[:country_code],
        CURRENCYCODE:  payment_params[:currency_code], #@paypal_config.country_currency_code, #,payment_params[:currency_code]
        EXPDATE: payment_params[:exp_date]
      }
      # begin
      # @response = Net::HTTP.post_form(URI.parse('https://api-3t.sandbox.paypal.com/nvp'), @hash)
      # rescue Timeout::Error
      #   return false, "Timeout due to reading, please try again"
      # end
      @response, error = make_paypal_api_call(@hash)
      if error.present?
        return false, error
      end
      @direct_pay = @response.body
      @transaction = CGI::parse(@direct_pay)
      if @transaction['ACK'].to_sentence  == "Failure" and @transaction['L_LONGMESSAGE0'].to_sentence.present? and @transaction['L_ERRORCODE0'].present?
        message = @transaction['L_LONGMESSAGE0'].to_sentence
        return true, message
      elsif @transaction['ACK'].to_sentence  == "Success"
        @amount = @transaction['AMT'].to_sentence.to_f/100
        @event_order_id = @order_id.to_i
        @transaction_id = @transaction['TRANSACTIONID'].to_sentence
        @status = 'success'
        @currency_code = payment_params[:currency_code] #'USD'
        @pg_sy_paypal_payment = create_paypal_payment(@amount, @event_order_id, @transaction_id, @status, @currency_code)
        return @pg_sy_paypal_payment
      else
        message = 'Error in payment'
        return true, message
      end
    end
  
    def create_paypal_payment(amount, event_order_id, transaction_id, status, currency_code , correlation_id)
      @paypal_payment = PgSyPaypalPayment.create(amount: @amount, event_order_id: @event_order_id, transaction_id: @transaction_id, status: @status, currency_code: @currency_code, correlation_id: correlation_id)
        if @paypal_payment.present?
            @event_order = PgSyPaypalPayment.paypal_order_payment(@paypal_payment)
            if @event_order.present?
              UserMailer.paypal_payment_success(@event_order, @paypal_payment).deliver
            end
        else
          message = 'no paypal payment found'
        end
      return @paypal_payment
    end
  
    def paypal_direct_payment_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      if refund_params != nil and config_id != nil and transaction_log != nil and false
        paypal_refund_params = refund_params
        transaction_id = paypal_refund_params[:transaction_id].to_s
        amount = (paypal_refund_params[:amount].to_f*100).to_i
        paypal_config = PgSyPaypalConfig.find(config_id)
        paypal_payment = PgSyPaypalPayment.find_by(transaction_id: transaction_id)
        paypal_refund_hash = {
          USER: paypal_config.username, #"sycinfinite-facilitator_api1.gmail.com"
          PWD: paypal_config.password, #'XMH9N548R345KHUS'
          SIGNATURE: paypal_config.signature, #"A48xhmaiuontCe9M-0tTDe137jpyADZcMN07-A73O7D8OF2rTGLV4GLp"
          METHOD: 'RefundTransaction',
          VERSION: ENV['PAYPAL_VERSION'],
          TRANSACTIONID: transaction_id,
          REFUNDTYPE: 'Partial',
          AMT: amount,
          CURRENCYCODE: paypal_payment.currency_code
        }
        # refund_response = Net::HTTP.post_form(URI.parse('https://api-3t.sandbox.paypal.com/nvp'), paypal_refund_hash)
        refund_response, error = make_paypal_api_call(paypal_refund_hash)
        if error.present?
          return true, error
        end
        refund_response = CGI::parse(refund_response.body)
        refund_response.each { |key,value| refund_response[key] = value[0] }
        if refund_response['ACK'] == 'Failure' and refund_response['L_ERRORCODE0'].present? and refund_response['L_LONGMESSAGE0'].present?
          return true, refund_response['L_LONGMESSAGE0']
        elsif refund_response['ACK'] == 'Success'
          # paypal_payment.update_attributes(total_refunded_amount: refund_response['TOTALREFUNDEDAMOUNT'].to_f, refund_id: refund_response['REFUNDTRANSACTIONID'])
          refund_response[:amount] = refund_response['GROSSREFUNDAMT'].to_f/100
          return refund_response
        else
          return true, 'Error in refund Paypal Direct Payment'
        end
      else
        # return true, 'No Configration found for Paypal Direct Payment or refund parameters missing'
        return true, 'Refund process for paypal is temporarily blocked, if you need refund please contact ashram.'
      end
    end
  
    # http://stackoverflow.com/questions/8206175/missing-amount-and-order-summary-in-paypal-express-checkout
    def paypal_express_checkout
      # render json: params
      # return false
      if paypal_express_checkout_params.has_key?('method') and paypal_express_checkout_params.has_key?('payment_request_0_amount') and paypal_express_checkout_params.has_key?('payment_request_0_payment_action') and paypal_express_checkout_params.has_key?('payment_request_0_currency_code') and paypal_express_checkout_params.has_key?('return_url') and paypal_express_checkout_params.has_key?('cancel_url') and paypal_express_checkout_params.has_key?('config_id') and paypal_express_checkout_params.has_key?('no_shipping') and paypal_express_checkout_params.has_key?('req_confirm_shipping') and paypal_express_checkout_params.has_key?('event_order_id')
        config_id = paypal_express_checkout_params[:config_id]
        @paypal_config = PgSyPaypalConfig.find(config_id)
        @event_order = EventOrder.find(paypal_set_payment_params[:event_order_id])
        @event = @event_order.event if @event_order.present?
        if @event.present? and @event.pay_in_usd?
          currency = 'USD'
        else
          currency = @paypal_config.country_currency_code if @paypal_config.present?
        end
        if @paypal_config.present?
          @express_pay_hash = {
            METHOD: 'SetExpressCheckout',
            PAYMENTREQUEST_0_AMT:  paypal_express_checkout_params[:payment_request_0_amount],
            PAYMENTREQUEST_0_PAYMENTACTION: paypal_express_checkout_params[:payment_request_0_payment_action],
            PAYMENTREQUEST_0_CURRENCYCODE: currency,# paypal_express_checkout_params[:payment_request_0_currency_code],
            PAYMENTREQUEST_0_DESC: paypal_express_checkout_params[:payment_request_0_desc],
            returnUrl: paypal_express_checkout_params[:return_url],
            cancelUrl: paypal_express_checkout_params[:cancel_url],
            VERSION: ENV['PAYPAL_VERSION'],
            USER: @paypal_config.username.to_s,
            PWD: @paypal_config.password.to_s,
            SIGNATURE: @paypal_config.signature.to_s,
            REQCONFIRMSHIPPING: paypal_express_checkout_params[:req_confirm_shipping],
            NOSHIPPING: paypal_express_checkout_params[:no_shipping]
            }
          # @response = Net::HTTP.post_form(URI.parse('https://api-3t.sandbox.paypal.com/nvp'), @express_pay_hash)
          @response, error = make_paypal_api_call(@express_pay_hash)
          if error.present?
            errorObj= {
              errors:{
                paypal_api_error: error
                }
            }
            render json:  errorObj, status: :unprocessable_entity
            return
          end
          @express_pay = @response.body
          @transaction = CGI::parse(@express_pay)
          if @transaction['ACK'].to_sentence  == "Success"
            render json: {token: @transaction['TOKEN']}
          elsif @transaction['L_LONGMESSAGE0'].to_sentence.present? and   @transaction['L_ERRORCODE0'].present?
            message = @transaction['L_LONGMESSAGE0'].to_sentence
            errorObj= {
              errors:{
                error: message
                }
              }
              render json:  errorObj, status: :unprocessable_entity
          else
            errorObj= {
              errors:{
                token: 'not found'
                }
              }
            render json:  errorObj, status: :unprocessable_entity
          end
        else
         errorObj= {
            errors:{
              config: 'Configuration not found'
              }
            }
         render json:  errorObj, status: :unprocessable_entity
        end
      else
        errorObj= {
          errors:{
            payment: 'parameter missing'
            }
          }
          render json:  errorObj, status: :unprocessable_entity
      end
    end
  
    def paypal_get_express_checkout_payment
      if paypal_set_payment_params.has_key?('token') and paypal_set_payment_params.has_key?('config_id') and paypal_set_payment_params.has_key?('method')
        config_id = paypal_set_payment_params[:config_id]
        @paypal_config = PgSyPaypalConfig.find(config_id)
        @express_checkout_payment_hash = {
            METHOD: paypal_set_payment_params[:method],
            VERSION: ENV['PAYPAL_VERSION'],
            USER: @paypal_config.username.to_s,
            PWD: @paypal_config.password.to_s,
            SIGNATURE: @paypal_config.signature.to_s,
            TOKEN: paypal_set_payment_params[:token].to_s
        }
  
        # @response = Net::HTTP.post_form(URI.parse('https://api-3t.sandbox.paypal.com/nvp'), @express_checkout_payment_hash)
        @response, error = make_paypal_api_call(@express_checkout_payment_hash)
        if error.present?
          errorObj= {
            errors:{
              paypal_api_error: error
              }
          }
          render json:  errorObj, status: :unprocessable_entity
          return
        end
        @express_pay = @response.body
        @transaction = CGI::parse(@express_pay)
        if @transaction['ACK'].to_sentence  == "Failure" and @transaction['L_LONGMESSAGE0'].to_sentence.present? and @transaction['L_ERRORCODE0'].present?
          message = @transaction['L_LONGMESSAGE0'].to_sentence
          errorObj= {
              errors:{
                get_payment: [message]
               }
              }
            render json:  errorObj, status: :unprocessable_entity
        elsif @transaction['ACK'].to_sentence  == "Success"
          # @payer_id = @transaction['PAYERID'].to_sentence
           render json: @transaction
        else
          message = 'Error in payment'
          errorObj= {
              errors:{
                get_payment: [message]
              }
            }
           render json:  errorObj, status: :unprocessable_entity
        end
      end
    end
  
    def paypal_do_express_checkout_payment
      if paypal_set_payment_params.has_key?('token') and paypal_set_payment_params.has_key?('payer_id') and paypal_set_payment_params.has_key?('config_id') and paypal_set_payment_params.has_key?('method') and paypal_set_payment_params.has_key?('event_order_id') and paypal_set_payment_params[:event_order_id].present? and paypal_set_payment_params[:method].present? and paypal_set_payment_params[:config_id].present? and paypal_set_payment_params[:payer_id].present? and paypal_set_payment_params[:token].present?
        @paypal_config = PgSyPaypalConfig.find(paypal_set_payment_params[:config_id])
  
        # Transaction Log
        gateway = TransferredEventOrder.gateways.find{|g| g[:controller] == self.class.to_s}
        transaction_log = TransactionLogsController.new.create(transaction_loggable_id: paypal_set_payment_params[:event_order_id], transaction_loggable_type: 'EventOrder', other_detail: other_detail)
  
        ### LINE 293-298 for verifying currency code ####
        @event_order = EventOrder.find(paypal_set_payment_params[:event_order_id])
        @event = @event_order.event if @event_order.present?
        if @event.present? and @event.pay_in_usd?
          currency = 'USD'
        else
          currency = @paypal_config.country_currency_code if @paypal_config.present?
        end
  
        @express_checkout_payment_hash = {
            METHOD: paypal_set_payment_params[:method],
            VERSION: ENV['PAYPAL_VERSION'],
            USER: @paypal_config.username.to_s,
            PWD: @paypal_config.password.to_s,
            SIGNATURE: @paypal_config.signature.to_s,
            PAYMENTREQUEST_0_AMT: paypal_set_payment_params[:payment_request_0_amount],
            PAYMENTREQUEST_0_PAYMENTACTION: paypal_set_payment_params[:payment_request_0_payment_action],
            PAYMENTREQUEST_0_CURRENCYCODE: currency,
            PAYMENTREQUEST_0_CUSTOM: transaction_log.id.to_s,
            TOKEN: paypal_set_payment_params[:token].to_s,
            PAYERID: paypal_set_payment_params[:payer_id]
        }
  
        # @response = Net::HTTP.post_form(URI.parse('https://api-3t.sandbox.paypal.com/nvp'), @express_checkout_payment_hash)
        @response, error = make_paypal_api_call(@express_checkout_payment_hash)
        # Update USER, PWD and SIGNATURE of payment hash Not loggable
        @express_checkout_payment_hash[:USER] = 'XXXXXXX'
        @express_checkout_payment_hash[:PWD] = 'XXXXXXX'
        @express_checkout_payment_hash[:SIGNATURE] = 'XXXXXXX'
        if error.present?
          errorObj= {
            errors:{
              paypal_api_error: error
              }
          }
          # Update transaction log
          transaction_log.update_attributes(gateway_request_object: @express_checkout_payment_hash, gateway_response_object: error, transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])
          render json:  errorObj, status: :unprocessable_entity
          return
        end
        @express_pay = @response.body
        @transaction = CGI::parse(@express_pay)
        logger.info(@transaction)
        if @transaction['ACK'].to_sentence  == "Failure" or @transaction['ACK'].to_sentence == "FailureWithWarning" and @transaction['L_LONGMESSAGE0'].to_sentence.present? and @transaction['L_ERRORCODE0'].present?
          message = @transaction['L_LONGMESSAGE0'].to_sentence
          errorObj= {
              errors:{
                get_payment: [message]
              }
              }
          @amount = paypal_set_payment_params[:payment_request_0_amount]
          @event_order_id = paypal_set_payment_params[:event_order_id]
          @transaction_id = @transaction['PAYMENTINFO_0_TRANSACTIONID'].present? ? @transaction['PAYMENTINFO_0_TRANSACTIONID'].to_sentence : ' '
          @status = 'failure'
          @currency_code = currency
          @correlation_id = @transaction['CORRELATIONID'].present? ?  @transaction['CORRELATIONID'].to_sentence : ' '
  
          # Update Transaction Log
          transaction_log.update_attributes(gateway_request_object: @express_checkout_payment_hash, gateway_response_object: @transaction, transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], gateway_transaction_id: @transaction_id, status: @status)
  
          logger.info "paypal api response"
          logger.info (@express_pay)
          logger.info "paypal api parsed response"
          logger.info (@transaction)
          logger.info "paypal api error code"
          logger.info (@transaction['L_ERRORCODE0'].to_sentence)
          logger.info "paypal api error message"
          logger.info (@transaction['L_LONGMESSAGE0'].to_sentence)
          @pg_sy_paypal_payment = create_paypal_payment(@amount, @event_order_id, @transaction_id, @status, @currency_code, @correlation_id)
          render json: @transaction, status: :unprocessable_entity
        elsif @transaction['ACK'].to_sentence  == "Success" or @transaction['ACK'].to_sentence == "SuccessWithWarning"
          @amount = paypal_set_payment_params[:payment_request_0_amount]
          @event_order_id = paypal_set_payment_params[:event_order_id]
          @transaction_id = @transaction['PAYMENTINFO_0_TRANSACTIONID'].to_sentence
          @status = 'success'
          @currency_code = paypal_set_payment_params[:payment_request_0_currency_code]
          @correlation_id = @transaction['CORRELATIONID'].present? ?  @transaction['CORRELATIONID'].to_sentence : ' '
  
          # Update Transaction Log
          transaction_log.update_attributes(gateway_request_object: @express_checkout_payment_hash, gateway_response_object: @transaction, transaction_type: TransactionLog.transaction_types[:pay], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol], gateway_transaction_id: @transaction_id, status: @status)
  
          @pg_sy_paypal_payment = create_paypal_payment(@amount, @event_order_id, @transaction_id, @status, @currency_code, @correlation_id)
            render json: @pg_sy_paypal_payment
        else
          message = 'Error in payment, please check parameters'
          errorObj= {
                errors:{
                  get_payment: [message]
                }
              }
            render json:  errorObj, status: :unprocessable_entity
        end
      end
    end
  
    def make_paypal_api_call(options = {})
      if options.present?
        uri = Rails.env.to_s == 'production' ? ENV['PAYPAL_PROD_API'] : ENV['PAYPAL_DEV_API']
        # uri = ENV['PAYPAL_DEV_API']
        begin
          response = Net::HTTP.post_form(URI.parse(uri), options)
          rescue Timeout::Error
            return false, "Timeout due to reading, please try again"
        end
        return response
      else
        return false, "Invalid data object."
      end
    end
  
    def paypal_express_checkout_club
      if paypal_params.has_key?('method') and paypal_params.has_key?('payment_request_0_amount') and paypal_params.has_key?('payment_request_0_payment_action') and paypal_params.has_key?('payment_request_0_currency_code') and paypal_params.has_key?('return_url') and paypal_params.has_key?('cancel_url') and paypal_params.has_key?('config_id') and paypal_params.has_key?('no_shipping') and paypal_params.has_key?('req_confirm_shipping') and paypal_params.has_key?('transaction_log_id') and paypal_params[:transaction_log_id].present? and paypal_params.has_key?('sy_club_id') and paypal_params[:sy_club_id].present?
        currency = 'USD'
        express_pay_hash = configure_paypal(paypal_params[:config_id])
        transaction_log = TransactionLog.find_by_id(paypal_params[:transaction_log_id])
        if express_pay_hash and transaction_log.present?
          express_pay_hash[:PAYMENTREQUEST_0_AMT] = paypal_params[:payment_request_0_amount]
          express_pay_hash[:PAYMENTREQUEST_0_PAYMENTACTION] = paypal_params[:payment_request_0_payment_action]
          express_pay_hash[:PAYMENTREQUEST_0_CURRENCYCODE] = currency
          express_pay_hash[:PAYMENTREQUEST_0_DESC] = paypal_params[:payment_request_0_desc]
          express_pay_hash[:returnUrl] = paypal_params[:return_url]
          express_pay_hash[:cancelUrl] = paypal_params[:cancel_url]
          express_pay_hash[:REQCONFIRMSHIPPING] = paypal_params[:req_confirm_shipping]
          express_pay_hash[:NOSHIPPING] = paypal_params[:no_shipping]
          paypal_response, error = make_paypal_api_call(express_pay_hash)
          if error.present?
            render json: {error: error}, status: :unprocessable_entity
            return
          end
          paypal_response = CGI::parse(paypal_response.body)
          paypal_response.each { |k, v| paypal_response[k.to_s] = v[0] }
          if paypal_response['ACK'] == "Success"
            other_detail = transaction_log.other_detail
            other_detail['paypal_token'] = paypal_response['TOKEN']
            transaction_log.update(other_detail: other_detail)
            render json: {token: [paypal_response['TOKEN']]}
          elsif paypal_response['L_LONGMESSAGE0'].present? and paypal_response['L_ERRORCODE0'].present?
            render json: {error: paypal_response['L_LONGMESSAGE0']}, status: :unprocessable_entity
          else
            render json: {token: 'not found'}, status: :unprocessable_entity
          end
        else
          render json: {config: 'Configuration not found'}, status: :unprocessable_entity
        end
      else
        render json: {payment: 'parameter missing'}, status: :unprocessable_entity
      end
    end
  
    def paypal_do_express_checkout_payment_club
      if paypal_params.has_key?('token') and paypal_params.has_key?('payer_id') and paypal_params.has_key?('config_id') and paypal_params.has_key?('method') and paypal_params.has_key?('transaction_log_id') and paypal_params[:transaction_log_id].present? and paypal_params[:method].present? and paypal_params[:config_id].present? and paypal_params[:payer_id].present? and paypal_params[:token].present? and paypal_params.has_key?('sy_club_id') and paypal_params[:sy_club_id].present?
        currency = 'USD'
        message = nil
        request_object = configure_paypal(paypal_params[:config_id])
        transaction_log = TransactionLog.find_by_id(paypal_params[:transaction_log_id])
        if transaction_log.other_detail['paypal_token'].to_s == paypal_params[:token].to_s
          if request_object
            request_object[:PAYMENTREQUEST_0_AMT] = paypal_params[:payment_request_0_amount]
            request_object[:PAYMENTREQUEST_0_PAYMENTACTION] = paypal_params[:payment_request_0_payment_action]
            request_object[:PAYMENTREQUEST_0_CURRENCYCODE] = currency
            request_object[:PAYMENTREQUEST_0_CUSTOM] = transaction_log.id.to_s
            request_object[:TOKEN] = paypal_params[:token].to_s
            request_object[:PAYERID] = paypal_params[:payer_id]
            paypal_response, message = make_paypal_api_call(request_object)
            # Update USER, PWD and SIGNATURE of payment hash Not loggable
            request_object[:USER] = 'XXXXXXX'
            request_object[:PWD] = 'XXXXXXX'
            request_object[:SIGNATURE] = 'XXXXXXX'
            paypal_response = CGI::parse(paypal_response.body)
            paypal_response.each { |k, v| paypal_response[k.to_s] = v[0] }
            logger.info(paypal_response)
            if ['Failure', 'FailureWithWarning'].include?(paypal_response['ACK']) and paypal_response['L_LONGMESSAGE0'].present? and paypal_response['L_ERRORCODE0'].present?
              status = 'failure'
              message = paypal_response['L_LONGMESSAGE0']
            elsif ['Success', 'SuccessWithWarning'].include?(paypal_response['ACK'])
              status = 'success'
              message = nil
            else
              message = 'Error in payment.'
            end
          else
            message = 'Paypal Configuration not found.'
          end
        else
          message = 'Token is invalid or expired'
        end
        # Update Transaction Log
        transaction_log.update(gateway_request_object: request_object, gateway_response_object: paypal_response.present? ? paypal_response : message, gateway_transaction_id: paypal_response['PAYMENTINFO_0_TRANSACTIONID'], status: status == 'success' ? status : 'failure')
        payment_detail_params = transaction_log.other_detail['payment_detail_params'].deep_symbolize_keys
        if message.nil? and paypal_response.present?
          paypal_payment = PgSyPaypalPayment.create(amount: paypal_params[:payment_request_0_amount], transaction_id: paypal_response['PAYMENTINFO_0_TRANSACTIONID'], status: status, currency_code: currency, correlation_id: paypal_response['CORRELATIONID'], sy_club_id: paypal_params[:sy_club_id], token: paypal_params[:token])
          # Update club members
          if SyClub.new.after_club_payment(paypal_payment, message, payment_detail_params)
            sy_club_members = SyClubMember.where(id: payment_detail_params[:association_ids])
            sadhak_profiles = SadhakProfile.where(id: sy_club_members.pluck(:sadhak_profile_id))
            render json: {payment: paypal_payment, sy_club_members: sy_club_members, sadhak_profiles: sadhak_profiles}
          else
            if paypal_payment.status == 'success'
              message = 'Your payment has been recieved but some error occured while updating your profile. Please contact to ashram and do not make other payment'.
            else
              message = 'Some error occured while updating your profile'
            end
            render json: {error: message}, status: :unprocessable_entity
          end
        else
          render json: {error: message}, status: :unprocessable_entity
        end
      end
    end
  
    def configure_paypal(config_id)
      paypal_config = PgSyPaypalConfig.find_by_id(config_id)
      if paypal_config.present?
        { USER: paypal_config.username, PWD: paypal_config.password, SIGNATURE: paypal_config.signature, VERSION: ENV['PAYPAL_VERSION'], METHOD: paypal_params[:method] }
      else
        false
      end
    end
  
    #to reduce the code length a common method to reun response
    def transaction_response(hash)
      @direct_pay = @response.body
      @transaction = CGI::parse(@direct_pay)
      if @transaction['ACK'].to_sentence  == "Failure" and @transaction['L_LONGMESSAGE0'].to_sentence.present? and @transaction['L_ERRORCODE0'].present?
        message = @transaction['L_LONGMESSAGE0'].to_sentence
        return true, message
      elsif @transaction['ACK'].to_sentence  == "Success"
        @amount = @transaction['AMT'].to_sentence.to_i
        # @event_order_id =
        @transaction_id = @transaction['TRANSACTIONID'].to_sentence
        @status = 'success'
        @currency_code = 'USD'#, payment_params[:currency_code]
        @pg_sy_paypal_payment = create_paypal_payment(amount: @amount, event_order_id: @event_order_id, transaction_id: @transaction_id, status: @status, currency_code: @currency_code)
        return @pg_sy_paypal_payment
      else
        message = 'Error in payment'
        return true, message
      end
    end
  
    def other_detail
      event_order = EventOrder.includes(:event_order_line_items).where(id: paypal_set_payment_params[:event_order_id]).last
      sadhak_profile_ids = event_order.event_order_line_items.collect{ |item| item.sadhak_profile_id }
      {amount: paypal_set_payment_params[:payment_request_0_amount], event_order_id: event_order.id, line_items: event_order.event_order_line_items.ids, sadhak_profiles: sadhak_profile_ids, guest_email: event_order.guest_email, config_id: paypal_set_payment_params[:config_id], event_id: event_order.event_id}
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_paypal_payment
        @pg_sy_paypal_payment = PgSyPaypalPayment.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_paypal_payment_params
        params.require(:pg_sy_paypal_payment).permit(:amount, :event_order_id, :status, :transaction_id, :invoice_number, :token, :redirect_url,:currency_code, :correlation_id)
      end
  
      def paypal_express_checkout_params
        params.require(:express_pay).permit(:method, :payment_request_0_amount, :payment_request_0_payment_action, :payment_request_0_currency_code, :return_url, :cancel_url, :config_id, :no_shipping, :req_confirm_shipping, :payment_request_0_desc, :event_order_id)
      end
  
      def paypal_set_payment_params
        params.require(:express_pay).permit(:method, :token, :config_id, :payer_id, :payment_request_0_amount, :payment_request_0_payment_action, :payment_request_0_currency_code,  :event_order_id)
      end
  
      def paypal_params
        params.require(:express_pay).permit!#(:method, :payment_request_0_amount, :payment_request_0_payment_action, :payment_request_0_currency_code, :return_url, :cancel_url, :config_id, :no_shipping, :req_confirm_shipping, :payment_request_0_desc)
      end
  end
end
