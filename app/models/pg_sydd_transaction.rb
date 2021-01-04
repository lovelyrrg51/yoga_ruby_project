class PgSyddTransaction < ApplicationRecord
  include AASM

  belongs_to :pg_sydd_merchant, optional: true
  belongs_to :event_order, optional: true
  belongs_to :sy_club, optional: true

  after_create :assign_transaction_id_to_event_order
  after_update :update_transaction_log, if: Proc.new{ |dd| status_changed? and PgSyddTransaction.statuses[dd.status] == PgSyddTransaction.statuses['approved'] }

  validates :dd_number, :dd_date, :bank_name, :amount, presence: true

  enum status: { pending: 0, approved: 1 }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :approved

    event :approve_details do
      transitions from: :pending, to: :approved
    end
  end

  def assign_transaction_id_to_event_order
    if self.event_order.present?
      verified_rc = SadhakProfile.new.verify_by_rc($current_user, self.event_order.event_id)
      if verified_rc
        status = 'dd_received_by_rc'
      elsif $current_user.india_admin?
        status = 'dd_received_by_india_admin'
      else
        status = self.event_order.status
      end
      self.event_order.update_attributes(transaction_id: self.dd_number, payment_method: 'Demand draft', status: status)
    end
  end

  # Method will update transaction log status on dd approved or received by ashram
  def update_transaction_log
    begin
      gateway = TransferredEventOrder.gateways.find{|g| g[:model] == self.class.to_s}
      log = self.event_order.transaction_logs.where(gateway_transaction_id: self.dd_number, status: TransactionLog.statuses['pending'], transaction_type: TransactionLog.transaction_types[:pay], gateway_name: gateway[:symbol]).last
      log.update(status: TransactionLog.statuses['success']) if log.present?
    rescue => e
      Rollbar.error(e)
    end
    errors.empty?
  end

  class << self

    def create_payment(sydd_transaction_params, transaction_log)
      begin
        raise 'DD Number cannot be blank.' unless sydd_transaction_params[:dd_number].present?
        raise 'DD Date cannot be blank.' unless sydd_transaction_params[:dd_date].present?
        raise 'Bank name cannot be blank.' unless sydd_transaction_params[:bank_name].present?
        raise 'Amount cannot be blank.' unless sydd_transaction_params[:amount].present?
        raise 'Please accept terms and conditions.' unless sydd_transaction_params[:is_terms_accepted].present?

        pg_sydd_transaction = PgSyddTransaction.create(:dd_number => sydd_transaction_params[:dd_number], dd_date: sydd_transaction_params[:dd_date], bank_name: sydd_transaction_params[:bank_name], amount: sydd_transaction_params[:amount], additional_details: sydd_transaction_params[:additional_details], is_terms_accepted: sydd_transaction_params[:is_terms_accepted], event_order_id: sydd_transaction_params[:event_order_id], sy_club_id: sydd_transaction_params[:sy_club_id])

        transaction_log.update_attributes(gateway_request_object: sydd_transaction_params.except(:details), gateway_response_object: pg_sydd_transaction.as_json, gateway_transaction_id: pg_sydd_transaction.dd_number, status: pg_sydd_transaction.status == 'approved' ? 'success' : 'pending', sy_pg_id: pg_sydd_transaction.id)
      rescue Exception => e
        message = e.message
      end

      return pg_sydd_transaction, message
    end

  end

end
