class CcavenuePayment
  attr_accessor :params, :controller_name

  def initialize(params, controller_name)
    @params = params
    @controller_name = controller_name
  end

  def call
    url_expire_after = 300
    payment_params = params.slice(:token, :order_id)
    check_exceptions(payment_params)
    payment = controller_name.constantize.find_by_m_payment_id(payment_params[:order_id])
    if controller_name == "OrderPaymentInformation"
      config = payment.try(:ccavenue_config)
    else
      config = payment.try(:hdfc_config)
    end
    check_ccavenue_and_find_event_order(config, url_expire_after, payment, payment_params)
    @event_order.update_columns(gateway_redirect_url: "#{@event_order.gateway_redirect_url}&used=true")
    return @event_order
  end

  private

  def check_exceptions(payment_params)
    # Validating some checks
    raise SyException, controller_name + "Controller: direct: Token is missing." unless payment_params[:token].present?
    raise SyException, controller_name + "Controller: direct: Order id is missing." unless payment_params[:order_id].present?
  end

  def check_ccavenue_and_find_event_order(config, url_expire_after, payment, payment_params)
    raise SyException, controller_name + "Controller: direct: Ccavenue configuration not found." unless config.present?
    @event_order = payment.try(:event_order)
    raise SyException, controller_name + "Controller: direct: Event order not found." unless @event_order.present?
    decrypt_token(config, url_expire_after, payment_params)
  end

  def decrypt_token(config, url_expire_after, payment_params)
    crypto = Crypto.new
    token = crypto.try(:decrypt, payment_params[:token], config.working_key)
    raise SyException, controller_name + "Controller: direct: There is some error in decryption of token." unless token.present?
    time_diff = Time.now.to_i - token.to_i  # Logic to check a valid time stamp niside token
    check_payment_exception(token, url_expire_after, time_diff)
  end

  def check_payment_exception(token, url_expire_after, time_diff)
    raise SyException, controller_name + "Controller: direct: Payment token has been expired.\nToken issue at: #{Time.at(token.to_i)}\nToken used at: #{Time.now}\nAllowed time difference is #{url_expire_after} seconds.\nTime difference is: #{time_diff}" if time_diff > url_expire_after
    raise SyException, controller_name + "Controller: direct: Redirect URL not found inside event_order." unless @event_order.gateway_redirect_url.present?
    raise SyException, controller_name + "Controller: direct: Payment URL is already used." if @event_order.gateway_redirect_url.include?("&used=true")
  end
end