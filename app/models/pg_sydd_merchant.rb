class PgSyddMerchant < ApplicationRecord
  validates :name, :domain, :public_key, :sms_limit, :private_key, presence: true
  validates :email, presence: true, length: { maximum: 255 }
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :sms_limit, numericality: { only_integer: true }
end
