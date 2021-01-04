class TransactionLog < ApplicationRecord
  belongs_to :transaction_loggable, polymorphic: true
  belongs_to :user, optional: true

  enum transaction_type: [ :pay, :refund ]
  enum gateway_type: [ :offline, :online]
  enum status: [ :failure, :success, :pending ]
  # FYI
  # gateway_name: [:cash,:stripe,:sydd,:razorpay,:braintree,:paypal ]

  serialize :gateway_request_object, JSON
  serialize :gateway_response_object, JSON
  serialize :other_detail, JSON
  serialize :request_params, JSON

  scope :transaction_log_id, ->(transaction_log_id) { where(id: transaction_log_id) }

  before_save :assign_user

  def assign_user
    self.user = $current_user
    self.ip = $ip
  end
end
