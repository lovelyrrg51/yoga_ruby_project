module Api::V1
  
  class CcEncryptController < BaseController
    before_action :authenticate_user!, :except => [:create]
    skip_before_action :verify_authenticity_token, :only => [:create]
    def create
      begin
        if params.has_key?("config_id")
          @ccavenue_config = CcavenueConfig.find(params[:config_id])
          @transaction_log = TransactionLog.find(params[:transaction_log_id])
          if @ccavenue_config.present?
            merchantData=""
            working_key= @ccavenue_config.working_key
            access_code=@ccavenue_config.access_code
            metadata = compute_metadata(@transaction_log)
  
            # to raise exception if currency is other than INR
            raise SyException, "Currency #{params[:currency]} not supported by Ccavenue gateway" if params[:currency] != "INR"
  
            # To add parameter in ccavenue for future use in callbacks
            metadata.each_with_index do |(k,v),index|
              params["merchant_param#{index+1}".to_sym] = v.to_s
            end
  
            params.each do |key,value|
              if key != "action" && key != "controller"
                merchantData += key+"="+value+"&"
                logger.info key+"="+value
              end
            end
            crypto = Crypto.new
            encrypted_data = crypto.encrypt(merchantData,working_key)
            decrypted_data = crypto.decrypt(encrypted_data, working_key)
            logger.info decrypted_data
          end
        end
      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        message = e.message
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
        message = e.message
      end
      if message.present?
        render json: {error: [message]}, status: :unprocessable_entity
      else
        render json: { :encRequest => encrypted_data, :merchant_id => @ccavenue_config.merchant_id.to_s, :access_code => access_code }.to_json
      end
    end
  
    def sbm_pay_by_card
      @order = Order.find(params[:order_id])
      order_num = params[:order_id] + "_" + Time.now.to_i.to_s
      currency = "480"
      redirect_url = Rails.application.config.app_base_url.to_s() + "/order/sbm_response"
      custom_params = {:order_id => params[:order_id], :line_items => params[:merchant_param1]}
      redirect_url = redirect_url + "?" + custom_params.to_query
  
      request_params = Hash.new
      request_params[:userName] = ENV['SBM_USER'].to_s()
      request_params[:password] = ENV['SBM_PASS'].to_s()
      request_params[:orderNumber] = order_num
      request_params[:amount] = params[:amount]
      request_params[:currency] = currency
      request_params[:returnUrl] = redirect_url
  
      uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_REGISTER_ENDPOINT'].to_s())
      uri.query = URI.encode_www_form(request_params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response_hash = JSON.parse response.body
  
      if response_hash.has_key?("errorCode")# and response_hash["errorCode"] == "1"
        # handle case when order already exists and not paid yet
        # currently handling by passing the current timestamp along with order id
        render json: { error: response_hash["errorMessage"] }, status: 400
      else
        #check for session
        session_request_params = Hash.new
        session_request_params[:userName] = ENV['SBM_USER'].to_s()
        session_request_params[:password] = ENV['SBM_PASS'].to_s()
        session_request_params[:MDORDER] = response_hash["orderId"]
        md_order_id = response_hash["orderId"]
        session_uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_SESSION_STATUS_ENDPOINT'].to_s())
        http = Net::HTTP.new(session_uri.host, session_uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        session_request = Net::HTTP::Post.new(session_uri.request_uri)
        session_request.set_form_data(session_request_params)
        session_response = http.request(session_request)
        session_response_hash = JSON.parse session_response.body
  
        # check if session response is valid
        if session_response_hash.has_key?("remainingSecs") and session_response_hash["remainingSecs"] > 0
  
          payment_request_params = Hash.new
          payment_request_params[:userName] = ENV['SBM_USER'].to_s()
          payment_request_params[:password] = ENV['SBM_PASS'].to_s()
          payment_request_params[:MDORDER] = md_order_id
          payment_request_params[:language] = "en"
          payment_request_params['$PAN'] = params[:card_number]
          payment_request_params['$CVC'] = params[:code]
          payment_request_params['$EXPIRY'] = params[:year].to_s() + params[:month].to_s()
          payment_request_params['TEXT'] = params[:customer_name]
  
          payment_uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_PAYMENT_ENDPOINT'].to_s())
          http = Net::HTTP.new(payment_uri.host, payment_uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          payment_request = Net::HTTP::Post.new(payment_uri.request_uri)
          payment_request.set_form_data(payment_request_params)
          payment_response = http.request(payment_request)
          payment_response_hash = JSON.parse payment_response.body
  
          if (payment_response_hash.has_key?("error") || payment_response_hash.has_key?("errorMessage"))
            render json: {error: payment_response_hash["errorMessage"]}, status: 400
          else
            # payment successful
            order_status_params = Hash.new
            order_status_params[:userName] = ENV['SBM_USER'].to_s()
            order_status_params[:password] = ENV['SBM_PASS'].to_s()
            order_status_params[:orderId] = md_order_id
            order_status_params[:language] = "en"
  
            order_status_uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_ORDER_STATUS_ENDPOINT'].to_s())
            http = Net::HTTP.new(order_status_uri.host, order_status_uri.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            order_status_request = Net::HTTP::Post.new(order_status_uri.request_uri)
            order_status_request.set_form_data(order_status_params)
            order_status_response = http.request(order_status_request)
            order_status_response_hash = JSON.parse order_status_response.body
  
            if order_status_response_hash.has_key?("OrderStatus") and order_status_response_hash["OrderStatus"] == 2
              #order success
              @order.purchased_line_items = params[:merchant_param1].split(/,/)
              @order.successful_payment
              @order.sbm_amount_paid = order_status_response_hash["Amount"]
              @order.sbm_response = order_status_response.body
              # sending confirmation email
              UserMailer.order_confirmation(current_user, @order).deliver
  
              ##################################################
              @order.currency = params[:currency]
              @order.billing_name = params[:billing_name]
              @order.billing_address = params[:billing_address]
              @order.billing_address_city = params[:billing_city]
              @order.billing_address_state = params[:billing_state]
              @order.billing_address_country = params[:billing_country]
              @order.billing_address_postal_code = params[:billing_zip]
              @order.billing_phone = params[:billing_tel]
              @order.billing_email = params[:billing_email]
              @order.final_line_items = params[:merchant_param1]
              @order.sbm_merchant_order_num  = order_num
              @order.sbm_order_id = order_status_response_hash["orderId"]
              ##################################################
  
              @order.save
              render json: {success: "Payment recieved successfully"}
            else
              if order_status_response_hash.has_key?("ErrorMessage")
                render json: {error: order_status_response_hash["ErrorMessage"]}, status: 400
              else
                render json: {error: "Payment failed"}, status: 400
              end
            end
          end
        else
          render json: { status: "Failed", hash: session_response_hash }, status: 400
        end
      end
  
  
    end
  
    def sbm_pay
      @order = Order.find(params[:order_id])
  
      amount = params[:amount]
      order_num = params[:order_id] + "_" + Time.now.to_i.to_s
      currency = "480"
      redirect_url = Rails.application.config.app_base_url.to_s() + "/order/sbm_response"
      custom_params = {:order_id => params[:order_id], :line_items => params[:merchant_param1]}
      redirect_url = redirect_url + "?" + custom_params.to_query
  
      request_params = Hash.new
      request_params[:userName] = ENV['SBM_USER'].to_s()
      request_params[:password] = ENV['SBM_PASS'].to_s()
      request_params[:orderNumber] = order_num
      request_params[:amount] = amount
      request_params[:currency] = currency
      request_params[:returnUrl] = redirect_url
  
      uri = URI.parse(ENV['SBM_URL'].to_s() + ENV['SBM_REGISTER_ENDPOINT'].to_s())
      uri.query = URI.encode_www_form(request_params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      logger.info uri.request_uri
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      logger.info response.body
      response_hash = JSON.parse response.body
  
      if response_hash.has_key?("errorCode") and response_hash["errorCode"] == "1"
        # handle case when order already exists and not paid yet
        # currently handling by passing the current timestamp along with order id
        render json: { status: "Failed", hash: response_hash }
      else
        @order.currency = params[:currency]
        @order.billing_name = params[:billing_name]
        @order.billing_address = params[:billing_address]
        @order.billing_address_city = params[:billing_city]
        @order.billing_address_state = params[:billing_state]
        @order.billing_address_country = params[:billing_country]
        @order.billing_address_postal_code = params[:billing_zip]
        @order.billing_phone = params[:billing_tel]
        @order.billing_email = params[:billing_email]
        @order.final_line_items = params[:merchant_param1]
        @order.sbm_merchant_order_num  = order_num
        @order.sbm_order_id = response_hash["orderId"]
        @order.save
        render json: response_hash
      end
    end
  
    # Compute meta data for stripe end
      def compute_metadata(transaction_log)
        other_detail = transaction_log.other_detail.deep_symbolize_keys
        event_order = EventOrder.find_by_id(other_detail[:event_order_id])
        descriptor = "ShivYog"+"-"+event_order.event_id.to_s+"-"+event_order.reg_ref_number
        metadata = {email: other_detail[:guest_email].to_s, descriptor: descriptor, transaction_log_id: transaction_log.id}
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
        return metadata
      end
  end
end
