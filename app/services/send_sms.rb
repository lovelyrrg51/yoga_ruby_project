# frozen_string_literal: true

require 'msg91ruby'
require 'net/http'
require 'net/https'
require 'uri'

class SendSms
  class << self

    def call(mobile, telephone_prefix, message_body, country_code)
      phone = Utilities::Mobile.new(mobile, country_code)
      if phone.india_number?
        with_msg91(phone.parsed_number, message_body)
      else
        with_twilio(phone.parsed_number, message_body)
      end
    end

    protected

    def with_twilio(mobile, message_body)
      url = "https://api.twilio.com/2010-04-01/Accounts/#{ENV['TWILIO_SID']}/Messages.json"
      uri = URI(url)
      req = Net::HTTP::Post.new(uri)
      req.set_form_data('To' => mobile, 'From' => '+1' + ENV['TWILIO_FROM'], 'Body' => message_body)
      req.basic_auth(ENV['TWILIO_SID'], ENV['TWILIO_TOKEN'])
      req_options = {
        use_ssl: uri.scheme == "https",
      }
      res = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(req)
      end

      raise StandardError, JSON.parse(res.body)["message"] if res.code.to_i > 300
      true
    rescue => e
      Rollbar.error(e)
      [false, e.message]
    end

    def with_msg91(mobile, message_body)
      params = {
        authkey: ENV['MSG91_AUTH_KEY'],
        mobiles: mobile,
        message: message_body,
        sender: ENV['MSG91_DEFAULT_SENDER_ID'],
        route: ENV['MSG91_ROUTE'],
        response: 'json'
      }
      uri = URI('http://control.msg91.com/api/sendhttp.php')
      response = Net::HTTP.post_form(uri, params)
      JSON.parse response.body
    end

  end
end
