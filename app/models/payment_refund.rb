class PaymentRefund < ApplicationRecord
  include AASM

  default_scope { where(is_deleted: false) }

  scope :requester_id, lambda { |requester_id| where(requester_id: requester_id) }
  scope :responder_id, lambda { |responder_id| where(responder_id: responder_id) }
  scope :event_id, lambda { |event_id| where(event_id: event_id) }
  scope :status, lambda { |status| where(status: status) }
  scope :event_order_id, lambda { |event_order_id| where(event_order_id: event_order_id) }
  scope :max_refundable_amount, lambda { |max_refundable_amount| where(max_refundable_amount: max_refundable_amount) }
  scope :event_cancellation_plan_id, lambda { |event_cancellation_plan_id| where(event_cancellation_plan_id: event_cancellation_plan_id) }
  scope :amount_refunded, ->(amount_refunded) { where(amount_refunded: amount_refunded)}
  scope :reg_ref_number, ->(reg_ref_number) { joins(:event_order).where(event_orders: {reg_ref_number: reg_ref_number.to_s.strip}) }
  scope :requester_name, ->(requester_name) { joins(:requester_user).where("users.name ILIKE ?", "%#{requester_name.to_s.strip}%") }

  serialize :request_object, JSON

  validates :event_id, :event_order_id, presence: true

  belongs_to :event
  belongs_to :event_order
  belongs_to :requester_user, class_name: 'User', foreign_key: 'requester_id', optional: true
  belongs_to :responder_user, class_name: 'User', foreign_key: 'responder_id', optional: true
  belongs_to :event_cancellation_plan, optional: true
  has_many :payment_refund_line_items, dependent: :destroy
  belongs_to :shifted_event_order, class_name: "EventOrder", foreign_key: "shifted_event_order_id", optional: true

  before_validation :assign_requester_and_ip, on: :create
  before_update :assign_responder
  before_update :update_dependent, if: :is_deleted_changed?
  before_update :update_children_on_request_cancel, if: Proc.new { |payment_refund| payment_refund.status_changed? and payment_refund.status == 'request_cancelled'}
  # after_save :perform_updation, if: Proc.new { |payment_refund| payment_refund.status == "refunded" }
  # after_update :determine_final_item_status, if: Proc.new { |payment_refund| payment_refund.status_changed? and payment_refund.status == 'refunded'}
  after_update :determine_final_item_status,  if: Proc.new { |payment_refund| payment_refund.status_changed? and payment_refund.status == 'refunded'}
  # after_update :generate_refund_vouchers,  if: Proc.new { |payment_refund| payment_refund.status_changed? && payment_refund.refunded? && payment_refund.cancellation? && payment_refund.event.sy_event_company_id.present? && payment_refund.amount_refunded.nonzero? }

  enum status: { requested: 0, refunded: 1, request_cancelled: 2, done: 3 }
  aasm column: :status, enum: true, whiny_transitions: false do
    state :requested, initial: true
    state :refunded
    state :request_cancelled
    state :done

    event :refund, before: [], guards: [], after_commit: [] do
      transitions from: :requested, to: :refunded
    end
  end

  enum action: {
    cancellation: 1,
    downgrade: 2,
    transfer: 3,
    transfer_downgrade: 4,
    update_record: 5,
    upgrade: 6
  }

  enum item_status: {
    cancelled: 0,
    transferred: 1,
    updated: 2,
    success: 3,
    cancelled_refunded: 4,
    cancelled_refund_pending: 5,
    upgraded: 6,
    downgraded: 7,
    name_changed: 8,
    shivir_changed: 9,
    downgrade_requested: 10,
    shivir_change_requested: 11,
    name_change_requested: 12,
    upgrade_requested: 13
  }

  def self.preloaded_data
    PaymentRefund.order(:id).includes({event: [{event_cancellation_plan: [:event_cancellation_plan_items]}]}, :event_order, :requester_user, :responder_user, :event_cancellation_plan, {payment_refund_line_items: [:event_registration, :event_order_line_item, :registered_sadhak_profile, :line_item_sadhak_profile, :event_seating_category_association, :sadhak_profile, {event: [:event_registrations]}]})
  end

  def perform_updation
    self.update_line_item_discount

    shifted_reg_ref_number = self.shifted_event_order.try(:reg_ref_number)

    self.payment_refund_line_items.each do |_item|

      next unless self.errors.empty?

      registration = _item.event_registration

      # Means this is trasferred event order case if shifted reg ref number present
      if shifted_reg_ref_number.present?

        # Update registration status only as this is transfer case update. # No call backs
        registration.update(status: _item.new_item_status)

        line_item = _item.event_order_line_item

        # Update line item status only as this is transfer case update. # Yes there is some call backs needed to be called.
        if line_item.update(transferred_ref_number: shifted_reg_ref_number, status: _item.new_item_status)

          # Update refund line item status as done. It is processed.
          unless _item.update(status: _item.class.statuses[:done])
            errors.add(:payment, "refund line item ##{_item.try(:id)} update error: #{_item.errors.full_messages.first}.")
          end

        else
          errors.add(:event, "line item ##{line_item.try(:id)} update error: #{line_item.errors.full_messages.first}.")
        end

      else

        # Update registration status, category and sadhak profile. # NO call back needed
        registration.update(event_seating_category_association_id: _item.event_seating_category_association_id, sadhak_profile_id: _item.sadhak_profile_id, status: _item.new_item_status)

        line_item = _item.event_order_line_item

        # Update event order line item, Yes we need to fire callbacks.
        if line_item.update(event_seating_category_association_id: _item.event_seating_category_association_id, sadhak_profile_id: _item.sadhak_profile_id, price: _item.try(:event_seating_category_association).try(:price), status: _item.new_item_status)

          unless _item.update(status: _item.class.statuses[:done])
            errors.add(:payment, "refund line item ##{_item.try(:id)} update error: #{_item.errors.full_messages.first}.")
          end

        else
          errors.add(:event, "line item ##{line_item.try(:id)} update error: #{line_item.errors.full_messages.first}.")
        end
      end
    end
  rescue => e
    Rollbar.error(e)
  end

  def update_line_item_discount
    Rails.logger.info("PaymentRefund, update_line_item_discount: Start")

    details = (self.request_object.deep_symbolize_keys[:details] || [])

    Rails.logger.info("PaymentRefund, update_line_item_discount: Details object is\n#{details}\n")

    discounted_line_items = EventOrderLineItem.where(id: details.collect{|d| d[:discounted_line_item_id]})

    details.each_with_index do |detail, index|

      Rails.logger.info("index: #{index}")

      discounted_line_item = discounted_line_items.find{|d| d.id == detail[:discounted_line_item_id].to_i}

      Rails.logger.info("Discounted line item #{discounted_line_item.present? ? '' : 'not'} found at index #{index} with id: #{detail[:discounted_line_item_id]}")

      Rails.logger.info("Error occured at index: #{index}, while updating line item discount, errors: #{discounted_line_item.errors.full_messages}") unless discounted_line_item.update(discount: detail[:discount])
    end
  rescue => e
    Rollbar.error(e)
  end

  # Update intermediate status or restore intermediate statuses of line items and registrations
  def update_intermediate_line_item_status(restore = false)
    self.payment_refund_line_items.each do |_item|
      line_item = _item.event_order_line_item

      errors.add(:event, "line item ##{line_item.try(:id)} update error: #{line_item.errors.full_messages.first}.") unless line_item.update(status: restore ? _item.old_item_status : _item.new_item_status)

      registration = _item.event_registration

      errors.add(:event, "line item ##{line_item.try(:id)} update error: #{line_item.errors.full_messages.first}.") unless registration.update(status: restore ? _item.old_item_status : _item.new_item_status)
      return errors.empty?
    end
  end

  # Do generate manual refund request report
  def self.do_generate_manual_refund_requests_file(payment_refunds)
    # Create header for file
    header = %w(PAYMENT_REFUND_STATUS REGISTRATION_STATUS REQUESTER_USER_SYID REQUESTER_USER_FULL_NAME FROM_SYID FROM_FULL_NAME FROM_MOBILE FROM_EMAIL TO_SYID TO_FULL_NAME TO_MOBILE TO_EMAIL FROM_SEATING_CATEGORY TO_SEATING_CATEGORY FROM_EVENT TO_EVENT REGISTRATION_NUMBER REG_REF_NUMBER REQUESTED_DATE ACTION PAYMENT_REFUND_ID)

    rows = []

    # Header for cancellation requests
    cancellation_header = %w(PAYMENT_REFUND_STATUS REGISTRATION_STATUS REQUESTER_USER_SYID REQUESTER_USER_FULL_NAME SYID FULL_NAME MOBILE EMAIL SEATING_CATEGORY REGISTRATION_NUMBER REG_REF_NUMBER REQUESTED_DATE ACTION PAYMENT_REFUND_ID)

    cancellation_rows = []

    payment_refunds.each do |payment_refund|

      # Iterate over each refund line item
      payment_refund.payment_refund_line_items.each do |_item|
        # Define row
        row = []

        # Payment refund status
        row.push(payment_refund.status.try(:humanize))

        # Registration Status
        row.push(EventOrder.template_status_mapper[_item.try(:event_registration).try(:status).to_s])

        # Requester user SYID
        row.push(payment_refund.try(:requester_user).try(:sadhak_profile).try(:syid))

        # Requester user full name
        row.push(payment_refund.try(:requester_user).try(:sadhak_profile).try(:full_name))

        # From SYID
        row.push(_item.try(:registered_sadhak_profile).try(:syid))

        # From full name
        row.push(_item.try(:registered_sadhak_profile).try(:full_name))

        # From mobile
        row.push(_item.try(:registered_sadhak_profile).try(:mobile))

        # From email
        row.push(_item.try(:registered_sadhak_profile).try(:email))

        # To SYID, full name, mobile, email
        unless [PaymentRefund.actions['cancellation']].include?(PaymentRefund.actions[payment_refund.action.to_s])
          if _item.try(:sadhak_profile_id) == _item.try(:registered_sadhak_profile).try(:id)
            row.push(nil)
            row.push(nil)
            row.push(nil)
            row.push(nil)
          else
            row.push(_item.try(:sadhak_profile).try(:syid))
            row.push(_item.try(:sadhak_profile).try(:full_name))
            row.push(_item.try(:sadhak_profile).try(:mobile))
            row.push(_item.try(:sadhak_profile).try(:email))
          end
        end

        # From seating category
        row.push(_item.try(:event_registration).try(:seating_category).try(:category_name))

        unless [PaymentRefund.actions['cancellation']].include?(PaymentRefund.actions[payment_refund.action.to_s])

          # To seating category
          row.push(_item.try(:event_seating_category_association_id) == _item.try(:event_registration).try(:event_seating_category_association_id) ? nil : _item.try(:seating_category).try(:category_name))

          # From event
          row.push(_item.try(:event_registration).try(:event).try(:event_name))

          # To event
          row.push(_item.try(:event_id) == _item.try(:event_registration).try(:event_id) ? nil : _item.try(:event).try(:event_name))
        end

        # Registration number
        row.push(_item.try(:event_registration).try(:event_order_line_item_id))

        # Reg ref number
        row.push(_item.try(:event_registration).try(:event_order).try(:reg_ref_number))

        # Requested date
        row.push(_item.created_at.try(:to_date).try(:to_s))

        # Action
        row.push(payment_refund.action.try(:titleize))

        # Payment refund id
        row.push(payment_refund.try(:id))

        if [PaymentRefund.actions['cancellation']].include?(PaymentRefund.actions[payment_refund.action.to_s])
          cancellation_rows.push(row)
        else
          # Push row
          rows.push(row)
        end

      end
    end

    {
      rows: rows,
      header: header,
      cancellation_rows: cancellation_rows,
      cancellation_header: cancellation_header
    }
  end

  def self.send_daily_manual_refund_report
    errors = []

    # Collect event admins to send report
    recipients = User.where(event_admin: true).includes(:sadhak_profile).collect{|u| u.try(:sadhak_profile).try(:email)}

    # Iterate over ready events only
    Event.where("events.status = ? and events.event_end_date >= ?", Event.statuses["ready"], Date.today - 1).includes(payment_refunds: [{payment_refund_line_items: [{event_registration: [:event_seating_category_association, :seating_category, :event, :event_order]}, :registered_sadhak_profile, :sadhak_profile, :event_seating_category_association, :seating_category, :event]}, {requester_user: [:sadhak_profile]}]).each do |event|
      begin

        # Generate data that will be feeded to generate excel method
        data = self.do_generate_manual_refund_requests_file(event.payment_refunds)

        # Create attachment hash
        attachments = Hash.new

        # Send email if rows are available
        if data[:rows].count > 0 or data[:cancellation_rows].count > 0

          # Reciepitents changed according to environment
          recipients = ENV['DEVELOPMENT_RESP'].extract_valid_emails if Rails.env == "development"
          recipients = ENV['TESTING_RESP'].extract_valid_emails if ENV["ENVIRONMENT"] == "testing"

          if data[:rows].count > 0
            # Generate excel file for downgrade/transfer requests
            blob = GenerateExcel.generate(data.slice(:rows, :header))

            # File name for downgrade/transfer requests
            file_name = "#{event.try(:event_name_with_location)}_registration_change_requests_(downgrade/transfer)_#{event.id}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"

            attachments["#{file_name}"] = blob
          end

          if data[:cancellation_rows].count > 0
            # Generate file for cancellation requests
            blob = GenerateExcel.generate(rows: data[:cancellation_rows], header: data[:cancellation_header])

            # File name for cancellation requests
            file_name = "#{event.try(:event_name_with_location)}_registration_change_requests_(cancellation)_#{event.id}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.xls"

            attachments["#{file_name}"] = blob
          end

          from = GetSenderEmail.call(event)

          # Email the report to evcent admins
          ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Registration Changes Report For : #{event.try(:event_name_with_location)} - #{DateTime.now.strftime('%F %T')} - #{DateTime.now.to_i}.", template: '', attachments: attachments).deliver
        end

      # Rescue from exceptions
      rescue SyException => e
        logger.info("Manula Exception: #{e.message}")
        errors.push(e.message)
      rescue Exception => e
        logger.info("Runtime Exception: #{e.message}")
        errors.push(e.message)
      end
    end

    errors
  end

  def process_report_generate(options = {})
    # Find event
    event = Event.where(id: options[:event_id]).includes(payment_refunds: [{payment_refund_line_items: [{event_registration: [:event_seating_category_association, :seating_category, :event, :event_order]}, :registered_sadhak_profile, :sadhak_profile, :event_seating_category_association, :seating_category, :event]}, {requester_user: [:sadhak_profile]}]).last

    # Generate data
    data = self.class.do_generate_manual_refund_requests_file(event.payment_refunds)

    if options[:type] == "cancellation"
      file_data = {rows: data[:cancellation_rows], header: data[:cancellation_header]}
    else
      file_data = data.slice(:rows, :header)
    end

    if file_data[:rows].size > 0
      if options[:format] == 'csv'
        blob = GenerateCsv.generate(file_data)
      elsif options[:format] == 'xls'
        blob = GenerateExcel.generate(file_data)
      end
    end

    if options[:send_email].present? and options[:email].present?
      begin
        from = GetSenderEmail.call(event)
        ApplicationMailer.send_email(from: from, recipients: options[:email], subject: "Event_Registration_Changes_Report_For_#{event.try(:event_name)}-#{event.try(:id)}_Dated_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.", attachments: Hash["#{event.event_name}_registrations_changes_report_#{options[:type]}_#{DateTime.now.strftime('%F %T')}_#{DateTime.now.to_i}.#{options[:format]}", blob]).deliver
      rescue Exception => e
        Rails.logger.info("Some error ocuured while sending email: PaymentRefund #process_report_generate, error: #{e.message}")
      end
    end

    # Return if download true
    return blob if options[:download]
  end

  # Send refund email - Async
  def refund_email(options = {})
    partial_refund = options[:partial_refund] || false
    refunds = options[:refunds] || []
    db_refunded_amount = options[:total_refunded_amount] || 0
    line_items = self.payment_refund_line_items.collect{|item| item.try(:event_order_line_item)}
    sadhak_profiles = line_items.collect{|item| item.try(:sadhak_profile)}
    syids = sadhak_profiles.collect{|s| s.try(:syid).to_s }.join(',')
    recipients = sadhak_profiles.collect{|s| s.try(:email)}
    event = self.event
    is_clp_event = event.get_clp_detail[:is_clp_event]
    from = GetSenderEmail.call(event)

    ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Refund Status ##{self.event_order.try(:reg_ref_number).to_s} ##{syids}", template: 'payment_refund_confirmation', refunds: refunds, line_items: line_items, event: event, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund).deliver if recipients.extract_valid_emails.size > 0 && !is_clp_event

    # Send copy of refund email to info@absclp.com in case of non-india event. In case of india event email to registration@shivyogindia.com
    recipients = ENV['DEVELOPMENT_RESP'].extract_valid_emails
    if ENV['ENVIRONMENT'] == 'production'
      recipients = event.is_in_india? ? 'registration@shivyogindia.com' : 'info@absclp.com'
    end
    ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Refund Status ##{self.event_order.try(:reg_ref_number).to_s} ##{syids}", template: 'payment_refund_confirmation', refunds: refunds, line_items: line_items, event: event, total_refunded_amount: db_refunded_amount, partial_refund: partial_refund).deliver
  end
  handle_asynchronously :refund_email

  private

  def assign_requester_and_ip
    self.requester_user = $current_user
    self.ip = $ip
  end

  def assign_responder
    self.responder_user = $current_user
  end

  def update_dependent
    if is_deleted
      payment_refund_line_items.destroy_all
    else
      PaymentRefundLineItem.restore(PaymentRefundLineItem.only_deleted.where(payment_refund_id: id).ids, recursive: true)
    end
    errors.empty?
  end

  def update_children_on_request_cancel
    if update_intermediate_line_item_status(true)
      payment_refund_line_items = self.payment_refund_line_items
      count = payment_refund_line_items.size
      errors.add(:there, 'is some error while updating payment refund line items.') if count != payment_refund_line_items.update_all(status: PaymentRefundLineItem.statuses['request_cancelled'])
    end
    errors.empty?
  end

  def determine_final_item_status
    mapper = {"cancelled_refund_pending" => "cancelled_refunded", "upgrade_requested" => "upgraded", "downgrade_requested" => "downgraded", "shivir_change_requested" => "shivir_changed", "name_change_requested" => "name_changed"}
    self.payment_refund_line_items.each do |item|
      final_item_status = EventRegistration.statuses[mapper[EventRegistration.statuses.key(item.new_item_status)]]
      item.update_column("new_item_status", final_item_status)
    end
  end

  def generate_refund_vouchers
    gateways = []

    refund_txns = event_order.transaction_logs.refund.select{|transaction_log| transaction_log.other_detail['payment_refund_id'] == id }

    if refund_txns.any?
      gateways = TransferredEventOrder.gateways.select{|g| refund_txns.collect(&:gateway_name).include?(g[:symbol]) }
    else
      payment_methods = event_order.transaction_logs.refund.last(1).collect{|transaction_log| transaction_log.other_detail['method'] }
      gateways = TransferredEventOrder.gateways.select{|g| payment_methods.include?(g[:payment_method]) }
    end

    mode_of_refund = gateways.collect{|g| g[:gateway_type] == 'online' ? 'Online' : g[:payment_method] }.collect(&:titleize).uniq.join('-')

    payment_refund_line_items.each do |_item|

      registration = _item.event_registration

      next unless registration.receipt_voucher.present? && !registration.refund_voucher.present?

      invoice = {}

      _event = event

      _event.event_cancellation_plan_id = event_cancellation_plan_id

      invoice[:mode_of_refund] = mode_of_refund

      invoice[:refunded_amount] = _item.event_order_line_item.price.to_f - _item.event_order_line_item.discount.to_f

      invoice[:cancellation_charges] = _event.cancellation_charges_by_policy([_item.event_order_line_item_id])

      invoice[:cgst] = {}

      invoice[:sgst] = {}

      invoice[:igst] = {}

      invoice[:recieved_amount] = invoice[:refunded_amount] - invoice[:cancellation_charges]

      registration.delay.generate_refund_voucher(invoice)

    end

    errors.empty?
  end

end
