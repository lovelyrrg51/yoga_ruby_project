class PgSyRazorpayConfig < ApplicationRecord
  validates :publishable_key, :secret_key, :alias_name, :payment_gateway,
    presence: true, uniqueness: true

  belongs_to :payment_gateway, dependent: :destroy

  # Razorpay.setup("rzp_test_YlYbIc87xu671w", "Sn53WvePnoGAHgyTnaGIMBcT")
  # Razorpay.setup("rzp_test_5zGJpFgQE3V9rF", "gjSY2j91TB0lhbnkTjhkuWKr")
  def configure
    Razorpay.setup(publishable_key, secret_key)
  end

  class << self

    def configure config_id
      find(config_id).configure
      true
    rescue Razorpay::Error, StandardError
      false
    end

  end
end
