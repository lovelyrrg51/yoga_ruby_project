class PaymentGatewayModeAssociation < ApplicationRecord
  acts_as_paranoid

  validates :payment_gateway, :payment_mode, :percent_type, presence: true
  validates :percent, presence: true, numericality: {greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, if: :fixed?
  validates :payment_mode, uniqueness: {scope: [:payment_gateway]}
  validates :payment_gateway_mode_association_ranges, length: { minimum: 1, message: 'Minimum 1 payment gateway range required.' }, if: :range?

  scope :payment_gateway_id, ->(payment_gateway_id) { where(payment_gateway_mode_associations: {payment_gateway_id: payment_gateway_id}) }
  scope :payment_mode_id, ->(payment_mode_id) { where(payment_gateway_mode_associations: {payment_mode_id: payment_mode_id}) }

  enum percent_type: [:fixed, :range]

  include AASM
  aasm column: :percent_type, enum: true do
    state :fixed, initial: true
    state :range
  end

  delegate :shortcode, to: :payment_mode

  belongs_to :payment_gateway
  belongs_to :payment_mode
  has_many :payment_gateway_mode_association_ranges, dependent: :destroy
  has_many :payment_gateway_mode_association_tax_types, dependent: :destroy

  accepts_nested_attributes_for :payment_gateway_mode_association_ranges, allow_destroy: true, reject_if: proc{ |attr| (attr['min_value'].to_i == 0) && (attr['max_value'] == "Infinity") && (attr['percent'].to_i == 0) }

  accepts_nested_attributes_for :payment_gateway_mode_association_tax_types, allow_destroy: true, reject_if: :all_blank

  after_update :revoke_payment_gateway_mode_association_ranges, if: :percent_type_changed? && :fixed?

  def transaction_charges(amount = 0)
    _percent = percent.to_f
    amount = amount.to_f
    if range?
      raise 'Minimum 1 payment gateway range required.' unless payment_gateway_mode_association_ranges.exists?
      payment_gateway_mode_association_range = payment_gateway_mode_association_ranges.where(":amount BETWEEN min_value AND max_value", {amount: amount}).last
      raise "Payment gateway range not found for amount: #{amount}" unless payment_gateway_mode_association_range.present?
      _percent = payment_gateway_mode_association_range.percent.to_f
    end
    return (amount * _percent.to_f / 100).rnd, _percent
  end

  def tax_on_transaction_charges(amount = 0)
    _transaction_charges, percent = transaction_charges(amount)
    txn_details = {total_transaction_charges: _transaction_charges, tax_breakup_on_convenience_charges: [], transaction_charges: _transaction_charges, total_taxes_on_transaction_charges: 0, percent: percent}
    tax_amount = 0
    payment_gateway_mode_association_tax_types.collect do |payment_gateway_mode_association_tax_type|
      tax_amount = (_transaction_charges * payment_gateway_mode_association_tax_type.percent.to_f / 100).rnd
      txn_details[:tax_breakup_on_convenience_charges] << {tax_name: payment_gateway_mode_association_tax_type.tax_type_name, amount: tax_amount, percent: payment_gateway_mode_association_tax_type.try(:percent)}
      txn_details[:total_transaction_charges] += tax_amount
      txn_details[:total_taxes_on_transaction_charges] += tax_amount
    end
    txn_details
  end

  def total_transaction_charges(amount = 0)
    tax_on_transaction_charges(amount)[:total_transaction_charges]
  end

  def total_taxes_on_transaction_charges(amount = 0)
    tax_on_transaction_charges(amount)[:total_taxes_on_transaction_charges]
  end

  def total_payable_amount(amount = 0)
    tax_details = tax_on_transaction_charges(amount)
    tax_details.merge({total_payable_amount: amount.to_f + tax_details[:total_transaction_charges]})
  end

  def revoke_payment_gateway_mode_association_ranges

    begin
      payment_gateway_mode_association_ranges.destroy_all
    rescue Exception => e
      throw :abort
    end

  end

end
