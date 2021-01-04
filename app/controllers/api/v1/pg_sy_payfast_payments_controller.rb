module Api::V1
  class PgSyPayfastPaymentsController < BaseController
    before_action :authenticate_user!, except: [:success, :cancel, :paid, :redirect]
    before_action :set_pg_sy_payfast_payment, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:success, :cancel, :paid, :redirect]
    respond_to :json

    # GET /pg_sy_payfast_payments
    def index
      @pg_sy_payfast_payments = PgSyPayfastPayment.all
      render json: @pg_sy_payfast_payments
    end

    # GET /pg_sy_payfast_payments/1
    def show
      authorize @pg_sy_payfast_payment
      render json: @pg_sy_payfast_payment
    end

    # GET /pg_sy_payfast_payments/new
    def new
      render json: {}
    end

    # GET /pg_sy_payfast_payments/1/edit
    def edit
      render json: {}
    end

    # POST /pg_sy_payfast_payments
    def create
      @pg_sy_payfast_payment = PgSyPayfastPayment.new(pg_sy_payfast_payment_params)
      authorize @pg_sy_payfast_payment
      if @pg_sy_payfast_payment.save
        render json: @pg_sy_payfast_payment
      else
        render json: @pg_sy_payfast_payment.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    # PATCH/PUT /pg_sy_payfast_payments/1
    def update
      authorize @pg_sy_payfast_payment
      if @pg_sy_payfast_payment.update(pg_sy_payfast_payment_params)
        render json: @pg_sy_payfast_payment
      else
        render json: @pg_sy_payfast_payment.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    # DELETE /pg_sy_payfast_payments/1
    def destroy
      authorize @pg_sy_payfast_payment
      if @pg_sy_payfast_payment.update(is_deleted: true)
        render json: @pg_sy_payfast_payment
      else
        render json: @pg_sy_payfast_payment.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end

    # POST /pg_sy_payfast_payments/paid
    def paid
      logger.info("PgSyPayfastPaymentsController: Raw Post:\n#{request.raw_post}")
      if PgSyPayfastPayment.payfast_paid(request.raw_post)
        head :bad_request
      else
        render nothing: true
      end
    end

    # GET /pg_sy_payfast_payments/success
    def success

      # Find payment and event order
      pg_sy_payfast_payment = PgSyPayfastPayment.where(m_payment_id: params[:order_id]).includes({event_order: [:event, {event_order_line_items: [:event, :sadhak_profile, :event_seating_category_association, :seating_category, :event_registration]}]}).last

      # If event order found
      if pg_sy_payfast_payment.try(:event_order).present?

        # Check it is processed and success
        if pg_sy_payfast_payment.processed? and pg_sy_payfast_payment.success?
          message = 'Payment Recieved.'

        # Check it is processed and failed
        elsif pg_sy_payfast_payment.processed? and pg_sy_payfast_payment.failed?
          message = 'Payment Failed.'

        # Check it is not processed and pending
        elsif not pg_sy_payfast_payment.processed? and pg_sy_payfast_payment.pending?
          message = "Please visit #{Rails.application.config.app_base_url}/#/registration-upgrades for final status after some time. If money deducted from your account and still showing status pending then Please contanct to Ashram."
        end

        if pg_sy_payfast_payment.event_order.sy_club_id.present?
          file_name = 'invoices/payfast_forum_payment_order_confirmation.html.erb'
        else
          file_name = 'invoices/payfast_confirmation_page.html.erb'
        end

        # Render file
        render file: "#{file_name}", :locals => {data: pg_sy_payfast_payment.event_order, message: message, status: pg_sy_payfast_payment.status}
      else
        logger.info("Not able to find order details with order id: #{params[:order_id]}")
        render file: "#{Rails.root}/public/404.html"
      end
    end

    # GET /pg_sy_payfast_payments/cancel
    def cancel
      # Find payment and event order
      pg_sy_payfast_payment = PgSyPayfastPayment.where(m_payment_id: params[:order_id]).includes({event_order: [:event, {event_order_line_items: [:event, :sadhak_profile, :event_seating_category_association, :seating_category, :event_registration]}]}).last

      # If event order found
      if pg_sy_payfast_payment.try(:event_order).present?

        message = "We did not recieve your payment. Either you cancelled this transaction or something went wrong."

        # Render file
        render file: "invoices/payfast_confirmation_page.html.erb", :locals => {data: pg_sy_payfast_payment.event_order, message: message, status: "cancelled"}
      else
        logger.info("Not able to find order details with order id: #{params[:order_id]}")
        render file: "#{Rails.root}/public/404.html"
      end
    end

    # GET /pg_sy_payfast_payments/redirect
    def redirect
      begin
        url_expire_after = 300

        logger.info("PgSyPayfastPaymentsController: direct: Start")

        # Getting order id and token
        payment_params = params.slice(:token, :order_id)
        logger.info("PgSyPayfastPaymentsController: direct: Params are\n#{payment_params}")

        # Validating some checks
        raise SyException, "PgSyPayfastPaymentsController: direct: Token is missing." unless payment_params[:token].present?
        raise SyException, "PgSyPayfastPaymentsController: direct: Order id is missing." unless payment_params[:order_id].present?

        payment = PgSyPayfastPayment.find_by_m_payment_id(payment_params[:order_id])
        payfast_config = payment.try(:pg_sy_payfast_config)

        raise SyException, "PgSyPayfastPaymentsController: direct: Payfast configuration not found." unless payfast_config.present?

        event_order = payment.try(:event_order)

        raise SyException, "PgSyPayfastPaymentsController: direct: Event order not found." unless event_order.present?

        # Decrypting token value
        crypto = Crypto.new

        token = crypto.try(:decrypt, payment_params[:token], payfast_config.merchant_key)

        raise SyException, "PgSyPayfastPaymentsController: direct: There is some error in decryption of token." unless token.present?

        logger.info("PgSyPayfastPaymentsController: direct: Decrypted token is\n#{token}")

        # Logic to check a valid time stamp niside token
        time_diff = Time.now.to_i - token.to_i

        raise SyException, "PgSyPayfastPaymentsController: direct: Payment token has been expired.\nToken issue at: #{Time.at(token.to_i)}\nToken used at: #{Time.now}\nAllowed time difference is #{url_expire_after} seconds.\nTime difference is: #{time_diff}" if time_diff > url_expire_after

        raise SyException, "PgSyPayfastPaymentsController: direct: Redirect URL not found inside event_order." unless event_order.gateway_redirect_url.present?

        raise SyException, "PgSyPayfastPaymentsController: direct: Payment URL is already used." if event_order.gateway_redirect_url.include?("&used=true")

        url = event_order.gateway_redirect_url

        event_order.update_columns(gateway_redirect_url: "#{event_order.gateway_redirect_url}&used=true")

      rescue SyException => e
        logger.info("Manual Exception: #{e.message}")
        is_error = true
      rescue Exception => e
        is_error = true
        logger.info("Runtime Exception: #{e.message}")
        logger.info(e.backtrace.inspect)
      end

      logger.info("PgSyPayfastPaymentsController: direct: End")

      if is_error
        render file: "#{Rails.root}/public/404.html"
      else
        redirect_to url
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_payfast_payment
        @pg_sy_payfast_payment = PgSyPayfastPayment.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_payfast_payment_params
        params.require(:pg_sy_payfast_payment).permit(:name_first, :name_last, :email_address, :m_payment_id, :amount, :item_description, :signature, :event_order_id, :status, :pf_payment_id, :amount_fee, :amount_net, :currency_code, :config_id)
      end
  end
end
