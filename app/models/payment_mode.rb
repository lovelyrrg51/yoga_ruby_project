class PaymentMode < ApplicationRecord
  acts_as_paranoid

  validates :name, :group_name, :shortcode, presence: true
  validates :name, uniqueness: {case_sensitive: false}

  enum group_name: [:net_banking, :credit_card, :debit_card, :mobile_payment, :cash_card, :emi, :ivrs, :wallet]

  scope :group_name, ->(group_name) { where(payment_modes: {group_name: group_name}) }
  scope :shortcode, ->(shortcode) { where(payment_modes: {shortcode: shortcode}) }
  scope :mode_name, ->(mode_name) { where('name ILIKE ?', "%#{mode_name}%") }

  has_many :payment_gateway_mode_associations, dependent: :destroy
  has_many :payment_gateways, through: :payment_gateway_mode_associations
end
