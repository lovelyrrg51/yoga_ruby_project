class StripeConfig < ApplicationRecord

  validates :alias_name, :payment_gateway, presence: :true
  validates_uniqueness_of :alias_name

  belongs_to :payment_gateway, dependent: :destroy
  validates :alias_name, uniqueness: true

  def configure
    Stripe.api_key = secret_key
  end

  class << self

    def configure config_id
      find(config_id).configure
      true
    rescue Stripe::StripeError, StandardError
      false
    end

  end
end
