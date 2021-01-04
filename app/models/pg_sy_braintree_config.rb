class PgSyBraintreeConfig < ApplicationRecord
  validates :publishable_key, :secret_key, :alias_name, :payment_gateway,
    presence: true, uniqueness: true

  belongs_to :payment_gateway, dependent: :destroy

  def configure
    Braintree::Configuration.environment = ENV.fetch('BRAINTREE_ENVIRONMENT'){ :sandbox }.to_sym
    Braintree::Configuration.merchant_id = merchant_id
    Braintree::Configuration.public_key = publishable_key
    Braintree::Configuration.private_key = secret_key
  end

  class << self

    def configure config_id
      find(config_id).configure
      true
    rescue Braintree::BraintreeError, StandardError
      false
    end

  end
end
