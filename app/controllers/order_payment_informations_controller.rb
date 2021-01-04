class OrderPaymentInformationsController < ApplicationController
  before_action :set_order_payment_information, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :except => [:redirect, :paid]
  skip_before_action :verify_authenticity_token, :only => [:redirect, :paid]

  # GET /order_payment_informations
  def index
    @order_payment_informations = OrderPaymentInformation.all
  end

  # GET /order_payment_informations/1
  def show
  end

  # GET /order_payment_informations/new
  def new
    @order_payment_information = OrderPaymentInformation.new
  end

  # GET /order_payment_informations/1/edit
  def edit
  end

  # POST /order_payment_informations
  def create
    @order_payment_information = OrderPaymentInformation.new(order_payment_information_params)

    if @order_payment_information.save
      redirect_to @order_payment_information, notice: 'Order payment information was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /order_payment_informations/1
  def update
    if @order_payment_information.update(order_payment_information_params)
      redirect_to @order_payment_information, notice: 'Order payment information was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /order_payment_informations/1
  def destroy
    @order_payment_information.destroy
    redirect_to order_payment_informations_url, notice: 'Order payment information was successfully destroyed.'
  end

  def paid

    event_order, message, status = OrderPaymentInformation.paid(params)

    status == 'success' ? flash[:success] = 'Payment received successfully.' : flash[:alert] = "Transaction Declined. Please try after some time."

    redirect_to event_order.sy_club ? complete_sy_club_path(event_order) : complete_event_order_path(event_order)

  end

  # GET /order_payment_informations/redirect
  def redirect

    begin

      url_expire_after = 300

      # Getting order id and token
      payment_params = params.slice(:token, :order_id)

      # Validating some checks
      raise SyException, "OrderPaymentInformationController: direct: Token is missing." unless payment_params[:token].present?
      raise SyException, "OrderPaymentInformationController: direct: Order id is missing." unless payment_params[:order_id].present?

      payment = OrderPaymentInformation.find_by_m_payment_id(payment_params[:order_id])
      ccavenue_config = payment.try(:ccavenue_config)

      raise SyException, "OrderPaymentInformationController: direct: Ccavenue configuration not found." unless ccavenue_config.present?

      event_order = payment.try(:event_order)

      raise SyException, "OrderPaymentInformationController: direct: Event order not found." unless event_order.present?

      # Decrypting token value
      crypto = Crypto.new

      token = crypto.try(:decrypt, payment_params[:token], ccavenue_config.working_key)

      raise SyException, "OrderPaymentInformationController: direct: There is some error in decryption of token." unless token.present?

      # Logic to check a valid time stamp niside token
      time_diff = Time.now.to_i - token.to_i

      raise SyException, "OrderPaymentInformationController: direct: Payment token has been expired.\nToken issue at: #{Time.at(token.to_i)}\nToken used at: #{Time.now}\nAllowed time difference is #{url_expire_after} seconds.\nTime difference is: #{time_diff}" if time_diff > url_expire_after

      raise SyException, "OrderPaymentInformationController: direct: Redirect URL not found inside event_order." unless event_order.gateway_redirect_url.present?

      raise SyException, "OrderPaymentInformationController: direct: Payment URL is already used." if event_order.gateway_redirect_url.include?("&used=true")

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_payment_information
      @order_payment_information = OrderPaymentInformation.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_payment_information_params
      params[:order_payment_information]
    end

end
