module Api::V1
  class OrderPaymentInformationsController < BaseController
    before_action :authenticate_user!, :except => [:create, :success, :cancel, :show]
    before_action :set_order_payment_information, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:create, :success, :cancel, :show]
  
    # GET /order_payment_informations
    def index
      @order_payment_informations = OrderPaymentInformation.all
      render json: @order_payment_informations
    end
  
    # GET /order_payment_informations/1
    def show
      @order_payment_information = OrderPaymentInformation.find(params[:id])
      render json: @order_payment_information
    end
  
    # GET /order_payment_informations/new
    def new
      @order_payment_information = OrderPaymentInformation.new
    end
  
    # GET /order_payment_informations/1/edit
    def edit
    end
  
    # POST /order_payment_informations
    def create(ccavenue_params = nil)
      if ccavenue_params != nil
        order_payment_information_params = ccavenue_params
        @order_payment_information = OrderPaymentInformation.create(:amount => order_payment_information_params[:amount], billing_name: order_payment_information_params[:billing_name], billing_address_city: order_payment_information_params[:billing_address_city], billing_address_postal_code: order_payment_information_params[:billing_address_postal_code], billing_address_country: order_payment_information_params[:billing_address_country], billing_phone: order_payment_information_params[:billing_phone], billing_email: order_payment_information_params[:billing_email], billing_address_state: order_payment_information_params[:billing_address_state], billing_address: order_payment_information_params[:billing_address], event_order_id: order_payment_information_params[:event_order_id], config_id: order_payment_information_params[:config_id])
        return  @order_payment_information
      end
      @order_payment_information = OrderPaymentInformation.new(order_payment_information_params)
      if current_user.present?
        @order_payment_information.user_id = current_user.id
      end
      @order_payment_information
      if @order_payment_information.save
        render json: @order_payment_information
      else
        render json: @order_payment_information.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /order_payment_informations/1
    def update
      if @order_payment_information.update(order_payment_information_params)
        render json: @order_payment_information
      else
        render json: @order_payment_information.errors, status: :unprocessable_entity
      end
    end
  
  
    def success
      descResp = decrypt_response
      order_details = params[:orderNo].split('-')
      transaction_log_id = descResp['merchant_param3']
      transaction_log = TransactionLog.find_by_id(transaction_log_id)
      Rails.logger.debug "#{descResp}"
  
      @order_payment_information = OrderPaymentInformation.find(order_details[2])
      @event_order = @order_payment_information.event_order
  
      if order_details[0].present? and not @order_payment_information.success?
        @order_payment_information.ccavenue_tracking_id = descResp['tracking_id']
        @order_payment_information.ccavenue_payment_mode = descResp['payment_mode']
        @order_payment_information.ccavenue_status_identifier = descResp['status_message']
        payment_detail_params = transaction_log.try(:gateway_request_object).try(:deep_symbolize_keys)
  
        if descResp['order_status'].downcase == 'success'
          @event_order.update_attributes(status: 1, transaction_id: descResp['tracking_id'], payment_method: 'Ccavenue Payment')
          # Added to update discounted amount and event registrations and line items
          begin
            @event_order.is_amount_valid?(payment_detail_params)
  
            # Update event order line items and event registrations as payment completed.
            @event_order.perform_updation(payment_detail_params[:details])
  
          rescue SyException => e
            logger.info("Manual Exception: #{e.message}")
          rescue Exception => e
            logger.info("Runtime Exception: #{e.message}")
            logger.info(e.backtrace.inspect)
          end
  
          status = 'success'
        else
          @event_order.update_attributes(status: 'failure', transaction_id: descResp['tracking_id'], payment_method: 'Ccavenue Payment') unless @event_order.success?
          status = 'failure'
          @event_order.notify_sadhak_about_payment_failure((payment_detail_params[:sadhak_profiles] || []).collect{|s| s[:event_order_line_item_id]})
        end
  
        # to assign status of order payment info
        @order_payment_information.status = status
  
        # To update the transaction log
        transaction_log.update_attributes(gateway_response_object: descResp, gateway_transaction_id: descResp['tracking_id'], status: @order_payment_information.status) if transaction_log.present?
  
        logger.info(transaction_log.inspect)
  
        if @order_payment_information.save and @order_payment_information.status == 'success'
          Rails.logger.info 'happy success+++++++++'
          if @order_payment_information.event_order.present?
            Rails.logger.info 'happy success<<<<<<<<<'
            # Send email as payment done
            @order_payment_information.event_order.reload.notify_joining if @order_payment_information.event_order.try(:event).try(:notification_service)
          end
        end
      end
  
      # Prepare template data for rendering after payment successful
      if descResp['failure_message'].present? and descResp['failure_message'] != 'null'
        @message = descResp['failure_message']
      elsif descResp['status_message'].present? and descResp['status_message'] == 'null'
        @message = ' '
      else
        @message = descResp['status_message']
      end
      @data = @event_order.reload
      if @data.sy_club_id.present?
        render file: 'invoices/ccavenue_forum_payment_confirmation.html.erb', :locals => {data: @data, message: @message, status: status}
      else
        render file: 'invoices/ccavenue_payment_confirmation.html.erb', :locals => {data: @data, message: @message, status: status}
      end
    end
  
    def cancel
      descResp = decrypt_response
      order_details = params[:orderNo].split('-')
      @order_payment_information = OrderPaymentInformation.find(order_details[2])
      transaction_log_id = descResp['merchant_param3']
      transaction_log = TransactionLog.find_by_id(transaction_log_id)
      logger.info descResp
      # type = @order_payment_information.event_order_id
      @order_payment_information.status = 'failure'#descResp["order_status"]
  
      #to Update transaction log details
      transaction_log.update_attributes(gateway_response_object: descResp, gateway_transaction_id: descResp["tracking_id"], status: @order_payment_information.status) if transaction_log.present?
  
      @order_payment_information.save
      @order_payment_information.event_order.update_attributes(status: 'failure', transaction_id: descResp["tracking_id"], payment_method: 'Ccavenue Payment') unless @order_payment_information.event_order.success?
  
      # Inform sadhaks about failed transaction
      payment_detail_params = transaction_log.gateway_request_object.deep_symbolize_keys
      @order_payment_information.event_order.notify_sadhak_about_payment_failure((payment_detail_params[:sadhak_profiles] || []).collect{|s| s[:event_order_line_item_id]})
  
      # url = get_url()
      # redirect_url = url +'/#/events/'+ event_id.to_s + '/register-success'+ "?" + "type" + "=" "#{type}" # for c9 cloud
      # redirect_to redirect_url
      if descResp['failure_message'].present? and descResp['failure_message'] != 'null'
        @message = descResp['failure_message']
      elsif descResp['status_message'].present? and descResp['status_message'] == 'null'
        @message = ' '
      else
        @message = descResp['status_message']
      end
      @data = @order_payment_information.event_order.reload
      if @data.sy_club_id.present?
        render file: "invoices/ccavenue_forum_payment_confirmation.html.erb", :locals => {data: @data, message: @message, status: "failure"}
      else
        render file: "invoices/ccavenue_payment_confirmation.html.erb", :locals => {data: @data, message: @message, status: "failure"}
      end
  
    end
  
    # DELETE /order_payment_informations/1
    def destroy
      @order_payment_information.destroy
      respond_to do |format|
        format.html { redirect_to order_payment_informations_url, notice: 'Order payment information was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    def get_url
      if ENV['ENVIRONMENT'] == 'testing'
        url = "https://syportal-dev.herokuapp.com"
      elsif ENV['ENVIRONMENT'] == 'production'
        url = "https://www.shivyogportal.com"
      else
        url = "localhost:4200"
      end
      return url
    end
  
    def ccavenue_refund(refund_params = nil, config_id = nil, transaction_log = nil)
      Rails.logger.info("OrderPaymentInformationsController: ccavenue_refund, Start")
      begin
        raise SyException, "Refund parameters missing - Ccavenue." unless refund_params.present?
        raise SyException, "Transaction log not found - Ccavenue." unless transaction_log.present?
        gateway_request_object = OrderPaymentInformation.find_by_id(refund_params[:id]).as_json
        refund_info = refund_params.as_json
        Rails.logger.info("OrderPaymentInformationsController: ccavenue_refund, gateway_request_object: #{gateway_request_object}")
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
      Rails.logger.info("OrderPaymentInformationsController: ccavenue_refund, refund_info: #{refund_info}")
      Rails.logger.info("OrderPaymentInformationsController: ccavenue_refund, message: #{message}")
      Rails.logger.info("OrderPaymentInformationsController: ccavenue_refund, End")
      return refund_params, message
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_order_payment_information
        @order_payment_information = OrderPaymentInformation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def order_payment_information_params
        params.require(:order_payment_information).permit(:amount, :billing_name, :billing_address, :billing_address_city, :billing_address_postal_code, :billing_address_country, :billing_phone, :billing_email, :ccavenue_tracking_id, :ccavenue_failure_message, :ccavenue_payment_mode, :ccavenue_status_code, :ccavenue_status_identifier, :billing_address_state, :status, :event_order_id, :config_id)
      end
  
     def decrypt_response
        # workingKey = Rails.application.config.app_working_key
        # get config id
        order_details = params[:orderNo].split('-')
        @order = OrderPaymentInformation.find(order_details[2])
        workingKey = CcavenueConfig.find(@order.config_id).working_key if @order.present?
        encResponse = params[:encResp]
        crypto = Crypto.new
        decResp=crypto.decrypt(encResponse,workingKey);
        logger.info decResp
        decResp = decResp.split("&")
        decMap = Hash.new
        decResp.each {|pair| logger.info pair; p_arr = pair.split("="); decMap[p_arr[0]] = p_arr[1]}
        decMap
      end
  end
end
