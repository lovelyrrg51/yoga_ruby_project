class PgSyPaypalStandardPayment < ApplicationRecord
  belongs_to :event_order
  belongs_to :sy_club

  enum status: { pending: 0, success: 1, failure: 2 }

  serialize :notification_params, JSON
  serialize :custom_data, JSON

  def paypal_url(options = {}, transaction_log)
    message = nil
    begin
      if options.present?
        paypal_standard_config, message = self.configure_paypal_standard(options[:config_id])
        currency_code = options[:currency_code].present? ? options[:currency_code].to_s.upcase : paypal_standard_config.currency_code.present? ? paypal_standard_config.currency_code.to_s.upcase : 'USD'
        if message.nil?
          values = {
            business: paypal_standard_config.business,
            cmd: '_xclick',
            upload: 1,
            return: options[:return_url].to_s.sub("_token_", generate_token({transaction_log_id: transaction_log.id})),
            cancel_url: options[:cancel_url],
            custom: transaction_log.id.to_s + "," + self.id.to_s,
            currency_code: currency_code,
            invoice: self.event_order_id.present? ? self.event_order_id : self.sy_club_id.present? ? (self.sy_club_id.to_s + "_" + Time.now.to_i.to_s) : Time.now.to_i.to_s,
            amount: self.amount,
            item_name: 'Shivyog Registration',
            no_note: 1,
            no_shipping: 1,
            quantity: '1',
            rm: '1',
            # notify_url: Rails.application.config.app_base_url.to_s()+ "/" + "hook"
            notify_url: ENV["PRE_PROD_URL"] + "/" + "hook"
          }
          uri =  self.select_uri + "?" + values.to_query
          transaction_log.update(gateway_request_object: values)
          self.update(currency_code: currency_code)
        end
      else
        message = "Please provide necessary parameters to paypal standard payment."
      end
    rescue Exception => e
      logger.info(e)
      logger.info(e.backtrace)
      logger.info("Error in paypal_url")
      message = e.message
    end
    return uri, message
  end

  def configure_paypal_standard(config_id)
    paypal_standard_config  = PgSyPaypalStandardConfig.find_by_id(config_id)
    if paypal_standard_config.present?
      return paypal_standard_config
    else
      return paypal_standard_config, "No paypal standard configuration found."
    end
  end

  def select_uri
    Rails.env == 'production' ? ENV['PAYPAL_STANDARD_PROD_API'] : ENV['PAYPAL_STANDARD_DEV_API']
  end

  def ipn(params)
    begin
      # connection = Connection.new(self.select_uri)
      # ipn_response = connection.post("?cmd=_notify-validate", params)
      url = self.select_uri
      url += "?cmd=_notify-validate"
      ipn_response = Net::HTTP.post_form(URI.parse(url), params)
      # ipn_response = CGI::parse(ipn_response.body)
    rescue Exception => e
      logger.info(e)
      logger.info("Error while verifying paypal standard payment.")
    end
    ipn_response
  end

end
