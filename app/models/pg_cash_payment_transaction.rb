class PgCashPaymentTransaction < ApplicationRecord
  include AASM

  belongs_to :event_order
  belongs_to :sy_club, optional: true

  after_create :generate_transaction_number

  validates :payment_date, :amount, presence: true

  enum status: { pending: 0, approved: 1 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :approved

    event :approve_details do
      transitions from: :pending, to: :approved
    end
  end

  def generate_transaction_number
    if self.event_order.present?
      number = SecureRandom.hex(6)
      self.update_attribute(:transaction_number, number)
      self.event_order.update_attributes(
        transaction_id: number,
        payment_method: 'Cash Payment',
        status: :success
      )
    end
  end

  class << self

    def create_payment(cash_transaction_params, transaction_log)
      begin
        cash_transaction_params[:additional_details] = "Cash Payement of #{cash_transaction_params[:amount]} has been received." unless cash_transaction_params[:additional_details].present?
        raise 'Please accept terms and conditions.' unless cash_transaction_params[:is_terms_accepted].present?

        # Create a new cash payment
        pg_cash_transaction = PgCashPaymentTransaction.create!(
          payment_date: cash_transaction_params[:payment_date],
          amount: cash_transaction_params[:amount],
          additional_details: cash_transaction_params[:additional_details],
          is_terms_accepted: cash_transaction_params[:is_terms_accepted],
          event_order_id: cash_transaction_params[:event_order_id],
          status: PgCashPaymentTransaction.statuses['approved'],
          sy_club_id: cash_transaction_params[:sy_club_id]
        )

        transaction_log.update_attributes(gateway_request_object: cash_transaction_params.except(:details), gateway_response_object: pg_cash_transaction.as_json, gateway_transaction_id: pg_cash_transaction.transaction_number, status: pg_cash_transaction.status == 'approved' ? 'success' : 'pending', sy_pg_id: pg_cash_transaction.id)
      rescue => e
        message = e.message
      end

      return pg_cash_transaction, message
    end

  end

end
