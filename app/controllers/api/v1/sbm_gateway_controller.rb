module Api::V1
  
  class SbmGatewayController < BaseController
    before_action :authenticate_user!
  
    def create
      sbm_user = "INNERSTRENGTH-API"
      sbm_pass = "Password1!"
      sbm_test_url = "https://202.191.186.125"
      register_endpoint = "/payment/rest/register.do"
      session_status_endpoint = "/payment/rest/getSessionStatus.do"
      payment_endpoint = "/payment/rest/processform.do"
      amount = "200";
      order_num = 16;
      currency = "480"
  #     redirect_url = "syportal-prod.herokuapp.com"
      redirect_url = "https://www.shivyogportal.com/"
  
      request_params = Hash.new
      request_params[:userName] = sbm_user
      request_params[:password] = sbm_pass
      request_params[:orderNumber] = order_num
      request_params[:amount] = amount
      request_params[:currency] = currency
      request_params[:returnUrl] = redirect_url
  
  
      uri = URI.parse(sbm_test_url + register_endpoint)
      uri.query = URI.encode_www_form(request_params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      logger.info uri.request_uri
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      logger.info response.body
      response_hash = JSON.parse response.body
  
      logger.info "Response hash is"
      logger.info response_hash
      logger.info response_hash["orderId"]
  
      session_request_params = Hash.new
      session_request_params[:userName] = sbm_user
      session_request_params[:password] = sbm_pass
      session_request_params[:MDORDER] = response_hash["orderId"]
      md_order_id = response_hash["orderId"]
      session_uri = URI.parse(sbm_test_url + session_status_endpoint)
      http = Net::HTTP.new(session_uri.host, session_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      logger.info session_uri.request_uri
      request = Net::HTTP::Post.new(session_uri.request_uri)
      request.set_form_data(session_request_params)
      response = http.request(request)
      logger.info response.body
      response_hash = JSON.parse response.body
  
      payment_request_params = Hash.new
      payment_request_params[:userName] = sbm_user
      payment_request_params[:password] = sbm_pass
      payment_request_params[:MDORDER] = md_order_id
      payment_request_params[:language] = "en"
      payment_request_params['$PAN'] = "4111111111111111"
      payment_request_params['$CVC'] = "123"
      payment_request_params['$EXPIRY'] = '201512'
      payment_request_params['TEXT'] = "X V"
  
      payment_uri = URI.parse(sbm_test_url + payment_endpoint)
      http = Net::HTTP.new(payment_uri.host, payment_uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      logger.info payment_uri.request_uri
      logger.info payment_request_params
      request = Net::HTTP::Post.new(payment_uri.request_uri)
      request.set_form_data(payment_request_params)
      response = http.request(request)
      logger.info response.body
      response_hash = JSON.parse response.body
      render json: response.body
    end
  end
end
