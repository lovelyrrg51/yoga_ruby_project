class EventOrder < ApplicationRecord
  extend FriendlyId

  friendly_id :generate_event_order_slug, use: [:slugged, :finders]

  default_scope { where(is_deleted: false) }

  has_paper_trail class_name: 'EventOrderVersion', only: [:event_id, :user_id, :registration_center_user_id, :status, :guest_email, :transaction_id, :payment_method, :registration_center_id, :reg_ref_number, :order_tax_detail], skip: [:total_tax_details, :tax_details], on: [:update, :destroy]

  diff :event_id, :user_id, :registration_center_user_id, :status, :guest_email, :transaction_id, :payment_method, :registration_center_id, :reg_ref_number, :order_tax_detail, :updated_at

  scope :event_id, lambda { |event_id| where(event_orders: {event_id: event_id}) }
  scope :registration_center_id, lambda { |registration_center_id| joins(:registration_center).where('registration_centers.id = ?', registration_center_id) }
  scope :reg_ref_number, lambda { |reg_ref_number| where(event_orders: {reg_ref_number: reg_ref_number.to_s.strip}) }
  scope :transaction_id, lambda { |transaction_id| where(event_orders: {transaction_id: transaction_id.to_s.strip}) }
  scope :payment_method, lambda { |payment_method| where('event_orders.payment_method ILIKE ?', "%#{payment_method.to_s.strip}%") }
  scope :first_name, lambda { |first_name| joins(:sadhak_profiles).where('sadhak_profiles.first_name ILIKE ?', "%#{first_name.to_s.strip}%") }
  scope :status, lambda { |status| where(event_orders: {status: status}) }

  scope :registered_by, ->(registered_by) { joins(user: :sadhak_profile).where("(sadhak_profiles.first_name ILIKE :registered_by) OR (sadhak_profiles.last_name ILIKE :registered_by) OR ((sadhak_profiles.first_name || '' || sadhak_profiles.last_name) ILIKE :registered_by) OR (sadhak_profiles.syid = :syid)", registered_by: "%#{registered_by.to_s.gsub(/\s+/, "")}%", syid: "sy#{registered_by.strip[/-?\d+/].to_i}".upcase) }

  scope :search_in_applied_sadhak_names, ->(search_in_applied_sadhak_names) { joins({event_order_line_items: [:sadhak_profile]}).where("(sadhak_profiles.first_name ILIKE :search_in_applied_sadhak_names) OR (sadhak_profiles.last_name ILIKE :search_in_applied_sadhak_names) OR ((sadhak_profiles.first_name || '' || sadhak_profiles.last_name) ILIKE :search_in_applied_sadhak_names) OR (sadhak_profiles.syid = :syid)", search_in_applied_sadhak_names: "%#{search_in_applied_sadhak_names.to_s.gsub(/\s+/, "")}%", syid: "sy#{search_in_applied_sadhak_names.strip[/-?\d+/].to_i}".upcase) }

  validates :event_id, presence: true

  after_save :after_successful_payment
  before_destroy :remove_transferred_order
  after_update :send_pre_approval_email, if: Proc.new { |eo| eo.event.present? and eo.event.pre_approval_required? and Event.statuses.slice(:test_registration, :ready).values.include?(Event.statuses[eo.event.status]) and EventOrder.statuses.slice(:approve, :rejected).values.include?(EventOrder.statuses[eo.status]) }
  after_update Proc.new {|eo| eo.delay.send_pre_approval_sms }, if: Proc.new { |eo| saved_change_to_status? and eo.approve? and eo.event.try(:pre_approval_required?) }

  # Callback if event is pre-approval and free then on application approve create registrations
  after_update :create_pre_approval_event_free_registrations, if: Proc.new { |eo| saved_change_to_status? and eo.approve? and eo.event.try(:pre_approval_required?) and eo.event.try(:free?) }

  before_save :check_dd_transaction
  before_create :create_order_tax_details, :assign_ref_number

  belongs_to :user, optional: true
  belongs_to :event
  delegate :event_name, to: :event, allow_nil: true
  belongs_to :registration_center_user, optional: true
  has_one :registration_center, through: :registration_center_user
  has_many :event_order_line_items, dependent: :destroy
  has_many :sadhak_profiles, through: :event_order_line_items
  has_many :event_registrations, dependent: :destroy
  has_many :pg_cash_payment_transactions, dependent: :destroy
  has_many :pg_sydd_transactions, dependent: :destroy
  has_many :order_payment_informations, dependent: :destroy
  has_many :stripe_subscriptions, dependent: :destroy
  has_many :pg_sy_razorpay_payments, dependent: :destroy
  has_many :pg_sy_braintree_payments, dependent: :destroy
  has_many :pg_sy_paypal_payments, dependent: :destroy
  has_many :pg_sy_payfast_payments, dependent: :destroy
  has_many :transaction_logs, as: :transaction_loggable
  has_many :valid_line_items, lambda { where(event_order_line_items: {status: EventOrderLineItem.valid_line_item_statuses}) }, class_name: 'EventOrderLineItem'
  has_many :registered_sadhak_profiles, lambda { where(event_registrations: {status: EventRegistration.valid_registration_statuses}) }, through: :event_registrations, source: :sadhak_profile
  has_many :valid_event_registrations, lambda { where(event_registrations: {status: EventRegistration.valid_registration_statuses}) }, class_name: 'EventRegistration'
  has_many :event_seating_category_associations, through: :valid_line_items, source: :event_seating_category_association
  belongs_to :sy_club, optional: true
  has_one :attachment, as: :attachable

  serialize :tax_details, JSON
  serialize :order_tax_detail, JSON
  serialize :total_tax_details, JSON

  delegate :email, to: :user, prefix: "user", allow_nil: true

  enum status:{pending: 0, success: 1, failure: 2, approve: 3, rejected: 4, dd_received_by_rc: 5, dd_received_by_ashram: 6, dd_received_by_india_admin: 7}
  include AASM
  aasm column: :status, enum: true do
    state :pending, initial: true
    state :dd_received_by_rc
    state :dd_received_by_india_admin
    state :dd_received_by_ashram
    state :success
    state :approve
    state :rejected
    state :failure

    event :pending do
      before do
        errors.add(:you, "are not allowed to change status from #{status} to pending.") unless approve? || rejected? || failure?
        errors.empty?
      end
      transitions from: [:approve, :rejected, :failure], to: :pending
    end

    event :approve do
      before do
        errors.add(:event, "is not pre approval.") unless event.try(:pre_approval_required?)
        errors.add(:you, "are not allowed to change status from #{status} to approve.") unless pending?
        errors.empty?
      end
      transitions from: :pending, to: :approve
    end

    event :rejected do
      before do
        errors.add(:event, "is not pre approval.") unless event.try(:pre_approval_required?)
        errors.add(:you, "are not allowed to change status from #{status} to reject.") unless pending?
        errors.empty?
      end
      transitions from: :pending, to: :rejected
    end

    event :failure do
      before do
        errors.add(:you, "are not allowed to change status from #{status} to failure.") unless pending? || approve?
        errors.empty?
      end
      transitions from: [:pending, :approve], to: :failure
    end

    event :success do
      before do
        errors.add(:you, "are not allowed to change status from #{status} to success.") unless pending? || approve? || success? || failure?
        errors.empty?
      end
      transitions from: [:pending, :approve, :success, :failure], to: :success
    end

    event :dd_received_by_rc do
      before do
        errors.add(:event, "is not configured for Demand draft payment.") unless (event.try(:payment_gateway_types).try(:pluck, :name) || []).include?('sydd')
        errors.add(:you, "are not allowed to change status from #{status} to dd received by rc.") unless pending?
        errors.empty?
      end
      transitions from: :pending, to: :dd_received_by_rc
    end

    event :dd_received_by_india_admin do
      before do
        errors.add(:event, "is not configured for Demand draft payment.") unless (event.try(:payment_gateway_types).try(:pluck, :name) || []).include?('sydd')
        errors.add(:you, "are not allowed to change status from #{status} to dd received by india admin.") unless pending?
        errors.empty?
      end
      transitions from: :pending, to: :dd_received_by_india_admin
    end

    event :dd_received_by_ashram do
      before do
        errors.add(:event, "is not configured for Demand draft payment.") unless (event.try(:payment_gateway_types).try(:pluck, :name) || []).include?('sydd')
        errors.add(:you, "are not allowed to change status from #{status} to dd received by Ashram.") unless pending?
        errors.empty?
      end
      transitions from: :pending, to: :dd_received_by_ashram
    end
  end

  def after_manual_status_update(transaction_id)

      raise "No Transaction Logs found." unless transaction_logs.present?

      # Update transaction log to success with respective gateway transaction id
      transaction_log = transaction_logs.pay.where(gateway_transaction_id: transaction_id).last
      transaction_log = transaction_logs.pay.where.not(status: TransactionLog.statuses[:success]).last unless transaction_log.present?

      raise "No Transaction Log found." unless transaction_log.present?

      transaction_log.update_columns(status: TransactionLog.statuses[:success]) unless transaction_log.success?
      transaction_log.update_columns(gateway_transaction_id: transaction_id) if transaction_log.try(:gateway_transaction_id) != transaction_id

      # Update Payment Entry in database to success with respective gateway transaction id
      gateway = TransferredEventOrder.gateways.find{|g| g.payment_method == payment_method }

      unless gateway.present?

        gateway_name = transaction_logs.pay.pluck(:gateway_name).uniq

        raise "Multiple Payment Gateways found in the Order." if gateway_name.count > 1

        gateway = TransferredEventOrder.gateways.find{|g| g.symbol == gateway_name.try(:first) }

      end

      raise "No Payment Gateway is attached to this Event Order." unless gateway.present?

      search_query = { event_order_id: id }
      search_query[gateway[:transaction_id]] = transaction_id
      transaction = Object.const_get(gateway[:model]).where(search_query).last
      transaction = Object.const_get(gateway[:model]).where(event_order_id: id).where("status IS NULL OR status != ?", gateway[:success]).last unless transaction.present?

      raise "No Payment Transaction found." unless transaction.present?

      transaction.update_columns(status: gateway[:success]) unless transaction.success?
      query = {}
      query[gateway[:transaction_id]] = transaction_id
      transaction.update_columns(query) if transaction.try(gateway[:transaction_id]) != transaction_id

      # Update event order transaction id with the shipped transaction_id
      self.update_columns(transaction_id: transaction_id, payment_method: gateway[:payment_method])

      request_params_details = transaction_log[:request_params].with_indifferent_access[:details]
      perform_updation(request_params_details)

  end

  def after_successful_payment
    ApplicationRecord.transaction do
      if EventOrder.statuses[self.status] == EventOrder.statuses['success']
        self.event_order_line_items.each do |item|
          self.event_registrations.create(user_id: self.user_id, event_seating_category_association_id: item.event_seating_category_association_id, sadhak_profile_id: item.sadhak_profile_id, event_id: self.event_id, is_extra_seat: item.is_extra_seat)
        end
        if self.payment_method == 'Demand draft'
          self.pg_sydd_transactions.last.update(status: PgSyddTransaction.statuses['approved'])
          # Send email as payment approved
          self.notify_joining if self.event.try(:notification_service)
        end
      elsif EventOrder.statuses[self.status] == EventOrder.statuses['dd_received_by_ashram'] and self.payment_method == 'Demand draft'
        self.pg_sydd_transactions.last.update(status: PgSyddTransaction.statuses['approved'])
        # Send email as payment approved
        self.notify_joining if self.event.try(:notification_service)
      end
    end
  end

  def self.update_transferred_order(new_event_order, event_order_params)
    # Variables declerations
    total_old_amount = 0.0
    total_new_amount = 0.0
    total_old_discount = 0.0
    total_new_discount = 0.0

    sadhak_profiles = event_order_params[:sadhak_profiles] || []

    # Raise error if no transferred event order entery found
    parent_child_mapper = TransferredEventOrder.find_by(child_event_order_id: new_event_order.id)
    raise SyException, "No transferred event order entery found for event order: #{new_event_order.id}" unless parent_child_mapper.present?

    # Find old event order
    old_event_order = EventOrder.includes(:event_order_line_items).find_by_id(parent_child_mapper.parent_event_order_id)
    raise SyException, "Parent event order is not present for event_order: #{new_event_order.id}" unless old_event_order.present?

    # Logic
    registrations = EventRegistration.includes(:event_seating_category_association, :event_order_line_item).where(event_order_line_item_id: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]})

    raise SyException, "No registrations found of parent event order: #{old_event_order.try(:id)}" if registrations.count == 0

    db_sadhaks = SadhakProfile.where(syid: sadhak_profiles.collect{|s| s[:syid]})

    new_line_items = new_event_order.event_order_line_items.includes(:event, :sadhak_profile).where(sadhak_profile_id: db_sadhaks.pluck(:id))

    sadhak_profiles.each do |sp|
      # Variables
      old_discount_per_sadhak = 0.0
      new_discount_per_sadhak = 0.0

      # Find sadhak profile
      db_sadhak = db_sadhaks.find{|s| s.syid == sp[:syid].to_s}
      raise SyException, "Sadhak profile not found." unless db_sadhak.present?

      # Find registration
      registration = registrations.find{|r| r.event_order_line_item_id == sp[:event_order_line_item_id].to_i}
      raise SyException, "Registration not found for: #{sp[:event_order_line_item_id]}." unless registration.present?

      new_line_item = new_line_items.find{|item| item.sadhak_profile_id == db_sadhak.id}
      raise SyException, "Line item not found for syid: #{sp[:syid]}" unless new_line_item.present?

      total_old_amount += registration.try(:event_seating_category_association).try(:price).to_f
      total_new_amount += new_line_item.try(:event_seating_category_association).try(:price).to_f

      old_discount_per_sadhak = registration.event_order_line_item.discount.to_f
      total_old_discount += old_discount_per_sadhak

      new_discount_per_sadhak = new_line_item.event.calculate_discount([sp.merge({syid: db_sadhak.id})]) if (db_sadhak.event_ids & (new_line_item.try(:event).try(:discount_plan).try(:event_ids) || [])).present?
      total_new_discount += new_discount_per_sadhak

      # Push data to sadhak profile as required later
      sp[:discounted_line_item] = new_line_item
      sp[:discount] = new_discount_per_sadhak
    end

    # Dicision based on total old amount paid and total new amount computed
    Rails.logger.info("EventOrder: update_transferred_order, total_old_amount: #{total_old_amount}")
    Rails.logger.info("EventOrder: update_transferred_order, total_old_discount: #{total_old_discount}")
    Rails.logger.info("EventOrder: update_transferred_order, total_new_amount: #{total_new_amount}")
    Rails.logger.info("EventOrder: update_transferred_order, total_new_discount: #{total_new_discount}")
    Rails.logger.info("EventOrder: update_transferred_order, Payable amount: #{total_new_amount - total_new_discount - total_old_amount + total_old_discount}")

    if (total_old_amount - total_old_discount) >= (total_new_amount - total_new_discount)
      # Update discount of each event order line item
      sadhak_profiles.each do |sp|
        discounted_line_item = sp[:discounted_line_item]
        discount = sp[:discount]
        raise SyException, "Error occured while updating line item discount: #{discounted_line_item.try(:id)}" unless discounted_line_item.update(discount: discount)
      end
      raise SyException, "Error occured while updating total discount event order: #{new_event_order.try(:id)}" unless new_event_order.update(status: 'success', transaction_id: "TRANSFER_FROM-#{old_event_order.reg_ref_number}-#{SecureRandom.base64(8).to_s}")
    end

  end

  def assign_ref_number
    self.reg_ref_number = loop do
      ref_number = Utilities::UniqueKeyGenerator.generate
      break ref_number unless EventOrder.exists?(reg_ref_number: ref_number)
    end
  end

  def update_parent_line_item_status(parent_event_order_id)
    self.event_order_line_items.each do |item|
      EventOrderLineItem.find_by(sadhak_profile_id: item.sadhak_profile_id, event_order_id: parent_event_order_id).update_attribute(:status, 'transferred')
      EventRegistration.find_by(sadhak_profile_id: item.sadhak_profile_id, event_order_id: parent_event_order_id).update_attribute(:status, 'transferred')
    end
  end

  def remove_transferred_order
    @transferred_orders = TransferredEventOrder.where(parent_event_order_id: self.id)
    @transferred_orders.destroy_all
    return true
  end

  # Method to validate event order payment amount
  def is_amount_valid?(options = {})
    # Raise is necessary parameters missing
    raise SyException, 'Please provide amount parameter.' unless options[:amount].present?
    raise SyException, 'Please provide sadhak profile list with seating category details.' unless options[:sadhak_profiles].present?
    raise SyException, 'Please provide valid payment method.' unless options[:gateway].present?
    raise SyException, 'Please provide config_id.' unless options[:config_id].present? unless %w(cash sydd).include?(options[:gateway][:symbol])

    # Assign needed data to local variables
    ui_amount = options[:amount].to_f
    line_items_ids = (options[:event_order_line_item_ids] || []).map { |x| x.to_i }
    sadhak_profiles = options[:sadhak_profiles]
    config_id = options[:config_id]
    gateway = options[:gateway]
    #the parent_event_order_id is always there in the options, so it convert "".to_i = 0
    parent_event_order_id = options[:parent_event_order_id].to_i.zero? ? nil : options[:parent_event_order_id].to_i

    # Compute gateway tax percentage filled while configuring through admin section
    gateway_tax_percentage = gateway[:config_model].try(:camelize).try(:constantize).try(:send, :find_by_id, config_id).try(:tax_amount).to_f

    total_old_amount = 0.0
    total_new_amount = 0.0
    total_old_discount = 0.0
    total_new_discount = 0.0
    details = []
    old_event_ids = []
    new_event_ids = []

    # discount feature_code in progress
    db_sadhaks = SadhakProfile.where(id: sadhak_profiles.collect{|sp| sp[:syid][/-?\d+/].to_i})
    categories = EventSeatingCategoryAssociation.includes(:event).where(id: sadhak_profiles.collect{|s| s[:event_seating_category_association_id]})
    # Run in case of transfer of event order
    if parent_event_order_id.present? && id != parent_event_order_id
      # Verify parent event order id
      raise SyException, "Parent event order id doesn't match." unless TransferredEventOrder.find_by(child_event_order_id: self.id, parent_event_order_id: parent_event_order_id).present?

      # Find parent event order
      @parent_eo = EventOrder.includes(:event_registrations, :event_order_line_items).find_by_id(parent_event_order_id)

      # Raise if no parent registrations found
      raise SyException, 'No event registrations found associated with parent event order. So transfer is not possible.' unless @parent_eo.try(:event_registrations).present?

      # Update line item ids
      line_items_ids = sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}

      # for updating transfered line item discount
      transferred_line_items = self.event_order_line_items.where(sadhak_profile_id: sadhak_profiles.collect{|sp| sp[:syid][/-?\d+/].to_i})
    end

    # Raise error if no line item ids found
    raise SyException, 'No line items found.' unless line_items_ids.present?

    seating_categories_requested = []

    # Run in case of upgrade and normal payment of event order
    EventOrderLineItem.includes(:event_seating_category_association, :event_registration, {event_order: [:event]}, :sadhak_profile ,{event: [{discount_plan: [:events]}]}).where(id: line_items_ids).each do |item|

      # To reset discount variables locally
      old_discount_per_sadhak = 0.0
      new_discount_per_sadhak = 0.0

      # Compute old price using existing seating category
      old_category_amount = item.try(:event_seating_category_association).try(:price).to_f
      total_old_amount += old_category_amount
      old_event_ids.push(item.try(:event_registration).try(:event_id))

      # Find sadhak profile object
      sp = sadhak_profiles.find{|s| s[:event_order_line_item_id].to_i == item.id}

      # Raise error if no sadhak profile object found
      raise SyException, "Please provide seating category details for SYID: SY#{item.sadhak_profile_id}." unless sp.present?

      db_sadhak = db_sadhaks.find{|s| s.id == sp[:syid][/-?\d+/].to_i}

      # Raise error if no sadhak profile object found
      raise SyException, "No sadhak profile found with SYID: SY#{sp[:syid]}." unless db_sadhak.present?

      # Find new category
      category = categories.find{|c| c.id == sp[:event_seating_category_association_id].to_i}
      raise SyException, "Seating category association not found with id: #{sp[:event_seating_category_association_id]}" unless category.present?
      new_category_amount = category.try(:price).to_f
      total_new_amount += new_category_amount
      new_event_ids.push(category.try(:event_id))

      scr = seating_categories_requested.find {|sc| sc[:id] == category.id }

      scr.blank? ? seating_categories_requested.push({ id: category.id, seats_requested: 1 }) : scr[:seats_requested] += 1

      # Logic to calculate old discount start
      cloned_sp = sp.clone
      cloned_sp[:event_seating_category_association_id] = item.try(:event_seating_category_association_id)
      cloned_sp[:syid] = item.try(:sadhak_profile_id)
      #old_discount_per_sadhak = item.event.calculate_discount([cloned_sp]) if (item.sadhak_profile.event_ids & (item.event.discount_plan.try(:event_ids)|| [])).present?
      old_discount_per_sadhak = item.discount.rnd
      total_old_discount += old_discount_per_sadhak
      # Logic to calculate old discount ends

      # Logic to calculate new discount start
      new_discount_per_sadhak = category.event.calculate_discount([sp]) if (db_sadhak.event_ids & (self.event.discount_plan.try(:event_ids) || [])).present?
      total_new_discount += new_discount_per_sadhak

      if parent_event_order_id.present? && id != parent_event_order_id

        line_item = transferred_line_items.find{|s| s.sadhak_profile_id == db_sadhak.id}
      else
        line_item = item
      end

      # Push data to details array as needed further after successful payment
      touched_columns = []
      touched_columns.push('event_seating_category_association_id') if item.event_seating_category_association_id != category.id
      touched_columns.push('sadhak_profile_id') if db_sadhak.id != item.sadhak_profile_id

      if touched_columns.size.zero? || touched_columns.include?('sadhak_profile_id') || item.event_seating_category_association.event_id != category.event_id
        raise SyException, "Name: #{db_sadhak.first_name} and SYID: #{db_sadhak.syid} is not allowed to register on event." if db_sadhak.banned?
        raise SyException, "Name: #{db_sadhak.first_name} and SYID: #{db_sadhak.syid} already registered for this event." unless !db_sadhak.events.include?(event) || (sy_club.present? && (db_sadhak.renewal_events || []).include?(event))
      end

      item_payable_amount = 0.0
      item_discount_amount = 0.0


      # To calculate tax details per registration, we need item payable and discounted amount
      if new_category_amount - new_discount_per_sadhak == old_category_amount - old_discount_per_sadhak || touched_columns.size.zero?
        item_payable_amount = new_category_amount
        item_discount_amount = new_discount_per_sadhak
      elsif (new_category_amount - new_discount_per_sadhak > old_category_amount - old_discount_per_sadhak) or (new_category_amount - new_discount_per_sadhak < old_category_amount - old_discount_per_sadhak)
        item_payable_amount = new_category_amount - old_category_amount
        item_discount_amount = new_discount_per_sadhak - old_discount_per_sadhak
      else
        raise SyException, "EventOrder: is_amount_valid : Something went wrong while computing updated details for line item: #{item.try(:id)}."
      end

      _cloned = sp.clone
      _cloned[:touched_columns] = touched_columns
      _cloned[:discounted_line_item_id] = line_item.id
      _cloned[:discount] = new_discount_per_sadhak
      _cloned[:sadhak_profile_id] = db_sadhak.id
      _cloned[:is_transferred] = item.event_seating_category_association.event_id != category.event_id
      _cloned[:transferred_ref_number] = _cloned[:is_transferred] ? self.reg_ref_number : nil
      _cloned[:item_id] = item.id
      _cloned[:category_id] = category.id
      _cloned[:item_payable_amount] = item_payable_amount
      _cloned[:item_discount_amount] = item_discount_amount
      _cloned[:gateway_tax_percentage] = gateway_tax_percentage
      _cloned[:status] = line_item.determine_final_status(_cloned)
      _cloned[:payment_gateway_mode_association_id] = options[:payment_gateway_mode_association_id]

      details.push(_cloned)

    end

    # Push details object to params
    options[:details] = details

    seating_categories_requested.each do |scr|

      event_seating_category_association_model = categories.find{ |sca| sca.id == scr.id }

      #check if EventSeatingCategoryAssociation belongs to the requested event
      raise SyException, "Seating category (#{event_seating_category_association_model.category_name}) does not belong to requested event." unless event_seating_category_association_model.event == event

      #check if number of seats requested are available in this category
      seats_occupied = event.valid_event_registrations.where(event_seating_category_association_id:  scr[:id]).count

      total_seats = event_seating_category_association_model.seating_capacity

      seats_available = total_seats - seats_occupied

      current_user = Global.instance.try(:current_user)

      unless current_user.present? and (current_user.super_admin? or current_user.event_admin?)
        if seats_available < scr[:seats_requested]
          if seats_available <= 0
            raise SyException, "No seats available in #{event_seating_category_association_model.seating_category.try(:category_name)} category."
          else
            raise SyException, "Only #{seats_available} seats are available in #{event_seating_category_association_model.seating_category.try(:category_name)} category"
          end
        end
      end
    end

    # Block updgrade or shivir transfer if CLP registration
    clp_event_ids = (GlobalPreference.get_value_of('india_clp_events').to_s.split(',') + GlobalPreference.get_value_of('global_clp_events').to_s.split(',')).map { |id| id.to_i }
    new_statuses = details.collect{|d| d[:status]}.uniq - [EventRegistration.statuses.success]
    raise SyException, 'Categoey, Shivir and Name Change is not allowed on CLP.' if (clp_event_ids & (new_event_ids.uniq + old_event_ids.uniq)).size > 0 and new_statuses.size > 0

    # Block upgrade or shivir changes for event type((1K)Shivir)
    raise 'Categoey, Shivir and Name Change is not allowed on 1k type shivir(s).' unless EventOrderPolicy.new($current_user, self).can_perform_registration_upgrade? && EventOrderPolicy.new($current_user, @parent_eo).can_perform_registration_upgrade? if new_statuses.size > 0
    # Decision based on computed amounts and discounts (old and new) if both are equal i.e normal event order payment, if total_new_amount is greater than old amount i.e transferred or upgrade case
    if total_new_amount - total_new_discount == total_old_amount - total_old_discount || details.pluck(:touched_columns).flatten.size.zero?
      db_payable_amount = total_new_amount
      total_discount_amount = total_new_discount
    elsif total_new_amount - total_new_discount > total_old_amount - total_old_discount
      db_payable_amount = total_new_amount - total_old_amount
      total_discount_amount = total_new_discount - total_old_discount
    else
      raise SyException, 'Unable to compute payable amount.'
    end

    amount_details = {original_amount: db_payable_amount, total_discount: total_discount_amount}

    total_payble_amount_with_tax = self.event.calculate_tax_amount(amount_details)

    if payment_gateway_mode_association = PaymentGatewayModeAssociation.find_by_id(options[:payment_gateway_mode_association_id])

      convenience_charges_detail = payment_gateway_mode_association.tax_on_transaction_charges(total_payble_amount_with_tax[:total_payable_amount])

      convenience_charges = convenience_charges_detail[:total_transaction_charges]

      total_payble_amount_with_tax.merge!(convenience_charges_detail)

    else

      convenience_charges = ((total_payble_amount_with_tax[:total_payable_amount] * gateway_tax_percentage).to_f / 100)

    end

    db_payable_amount = total_payble_amount_with_tax[:total_payable_amount] + convenience_charges

    total_payble_amount_with_tax[:convenience_charges] = convenience_charges

    total_payble_amount_with_tax[:total_payable_amount] = db_payable_amount.rnd

    self.update_column('tax_details', total_payble_amount_with_tax)

    Rails.logger.info("EventOrder: is_amount_valid : Final payble amount including all charges and taxes: #{db_payable_amount}")
    ui_amount.rnd == db_payable_amount.rnd
  end

  def other_detail(options = {})
    line_items_ids = options[:event_order_line_items_ids].present? ? options[:event_order_line_items_ids] : self.event_order_line_items.ids

    sadhak_profile_ids = options[:sadhak_profiles].present? ? options[:sadhak_profiles].collect { |sp| sp[:syid] } : self.event_order_line_items.pluck(:sadhak_profile_id)

    amount = options[:amount].present? ? options[:amount] : self.total_amount

    if options[:gateway].present? && options[:registration_payment_summary].present? && options[:gateway].present?
      total_payable_amount = options[:registration_payment_summary][:total_payable_amount].rnd
      gateway_tax_percentage = (Object.const_get options[:gateway][:config_model].try(:classify)).try(:where, { id: options[:config_id] }).try(:last).try(:tax_amount).to_f
      @gateway_charges = { gateway_tax_percentage: gateway_tax_percentage, amount: ((total_payable_amount * gateway_tax_percentage).to_f / 100).rnd, total_amount: (total_payable_amount + ((total_payable_amount * gateway_tax_percentage).to_f / 100).rnd) }
    end

    {amount: amount, event_order_id: self.id, line_items: line_items_ids, sadhak_profiles: sadhak_profile_ids, guest_email: self.guest_email, config_id: options[:config_id], event_id: self.event_id, gateway_charges: @gateway_charges, tax_details: options[:registration_payment_summary] }
  end


  def tax_details_for_upgrade(options = {})
    # Get sadhak profiles and amount details in upgrade/transfer cases
    result = pay_or_refund({sadhak_profiles: options[:sadhak_profiles], event_id: event.id })

    amount_hash = { original_amount: (result[:total_new_price] - result[:total_old_price]).rnd, total_discount: (result[:total_new_discount] - result[:total_old_discount]).rnd }

    event.calculate_tax_amount(amount_hash).merge(amount_hash)
  end


  def compute_info(options = {})
    total_old_price = 0.0
    total_new_price = 0.0
    details = []
    to_event_ids = []
    from_event_ids = []
    total_old_discount = 0.0
    total_new_discount = 0.0
    discount_deduction = 0.0

    sadhak_profiles = options[:sadhak_profiles] || []
    reg_ref_number = options[:reg_ref_number]

    # Collect all registrations using line item ids
    registrations = EventRegistration.includes(:event_seating_category_association, :event_order_line_item).where(event_order_line_item_id: sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]})


    # get all sadhaks for given order discount_feature process
    db_sadhaks = SadhakProfile.where(id: sadhak_profiles.collect{|sp| sp[:syid][/-?\d+/].to_i})

    # Collect seating category associations using seating category association id
    seating_category_associations = EventSeatingCategoryAssociation.where(id: sadhak_profiles.collect{|sp| sp[:event_seating_category_association_id]})

    sadhak_profiles.each do |sadhak_profile|

      # reset discount values
      old_discount_per_sadhak = 0.0
      new_discount_per_sadhak = 0.0

      # Find registration
      registration = registrations.find{|r| r.event_order_line_item_id == sadhak_profile[:event_order_line_item_id].to_i}

      # FInd category
      category = seating_category_associations.find{|a| a.id == sadhak_profile[:event_seating_category_association_id].to_i}

      new_sadhak  = db_sadhaks.find{|r| r.id == sadhak_profile[:syid][/-?\d+/].to_i}

      # Next if atleast one is not present
      next unless registration.present? and registration.try(:event_seating_category_association_id).present? and category.present? and new_sadhak.present?

      # Hold old and new discount########

      cloned_sp = sadhak_profile.clone
      cloned_sp[:event_seating_category_association_id] = registration.try(:event_seating_category_association_id)
      cloned_sp[:syid] = registration.try(:sadhak_profile_id)

      old_discount_per_sadhak = registration.try(:event_order_line_item).try(:discount).to_f
      total_old_discount += old_discount_per_sadhak

      new_discount_per_sadhak = category.event.calculate_discount([sadhak_profile]) if category.event.discount_plan.present? and (new_sadhak.event_ids & category.event.discount_plan.event_ids).present?
      total_new_discount += new_discount_per_sadhak

      # Hold old and new prices
      _old = registration.try(:event_seating_category_association).try(:price).to_f
      _new = category.try(:price).to_f

      # Aggregate old and new price
      total_old_price += _old
      total_new_price += _new

      touched_columns = []
      touched_columns.push('event_seating_category_association_id') if registration.event_seating_category_association_id != category.id
      touched_columns.push('sadhak_profile_id') if sadhak_profile[:syid].to_i != registration.sadhak_profile_id

      # Logic to compute wether transfer case or not
      to_event_ids.push(category.try(:event_id))
      from_event_ids.push(registration.try(:event_id))

      if self.reg_ref_number == reg_ref_number
        item = registration.event_order_line_item
      else
        item = self.event_order_line_items.where(sadhak_profile_id: new_sadhak.id).last
      end

      # Clone sadhak profile
      _cloned = sadhak_profile.clone
      _cloned[:touched_columns] = touched_columns
      _cloned[:event_registration_id] = registration.id
      _cloned[:discounted_line_item_id] = item.id
      _cloned[:discount] = new_discount_per_sadhak
      _cloned[:is_transferred] = registration.event_id != category.event_id
      _cloned[:transferred_ref_number] = _cloned[:is_transferred] ? self.reg_ref_number : nil
      _cloned[:old_item_status] = registration.status
      _cloned[:category_amount_diff] = _old - _new

      logger.info("EventOrder: compute_info: details for SYID: #{sadhak_profile[:syid]}\n#{_cloned.inspect}")

      details.push(_cloned)
    end

    # Logic to compute wether transfer case or not
    to_event_ids = to_event_ids.uniq
    from_event_ids = from_event_ids.uniq
    raise SyException, "All new seating category should be belong to same event: #{to_event_ids}" if to_event_ids.count > 1
    raise SyException, "All old seating category should be belong to same event: #{from_event_ids}" if from_event_ids.count > 1

    # Save these details to database with request params
    options[:details] = details


    # Decide amount : if no category or sadhak profile modified means cancellation
    amount = 0.0
    extra_discount = 0.0
    if details.collect{|d| d[:touched_columns]}.flatten.count == 0
      amount = total_old_price
      extra_discount = total_old_discount
    else
      amount = (total_old_price - total_new_price)
      extra_discount = total_old_discount - total_new_discount
    end
    amount -= extra_discount

    if details.collect{|d| d[:touched_columns]}.flatten.count == 0
      is_downgraded = false
    else
      is_downgraded = (total_old_price - total_old_discount - total_new_price + total_new_discount) > 0.0
    end

    return {amount: amount.rnd, is_downgraded: is_downgraded, details: details, is_transfer: (to_event_ids.last != from_event_ids.last)}
  end

  # Method used to update event order line item and event registration status, sadhak profile and event seating category association
  def perform_updation(details)
    begin

      details =  details || []

      discounted_line_items = EventOrderLineItem.where(id: details.collect{|d| d[:discounted_line_item_id]})
      event_order_line_items = EventOrderLineItem.where(id: details.collect{|d| d[:item_id]})
      seating_category_associations = EventSeatingCategoryAssociation.where(id: details.collect{|d| d[:category_id]}).includes(:seating_category)
      payment_gateway_mode_association = PaymentGatewayModeAssociation.find_by_id(details.collect{ |d| d[:payment_gateway_mode_association_id] }.uniq.last)

      (details || []).each_with_index do |detail, index|
        begin

          discounted_line_item = discounted_line_items.find{|d| d.id == detail[:discounted_line_item_id].to_i}
          discount = detail[:discount]
          status = detail[:status]
          is_transferred = detail[:is_transferred]
          transferred_ref_number = detail[:transferred_ref_number]
          sadhak_profile_id = detail[:sadhak_profile_id]
          item = event_order_line_items.find{|i| i.id == detail[:item_id]}
          category = seating_category_associations.find{|s| s.id == detail[:category_id]}

          # Calculate tax details if there is some amount to pay
          if detail[:item_payable_amount] - detail[:item_discount_amount] > 0
            begin
              # Calculate tax details per item
              tax_details = self.event.calculate_tax_amount(original_amount: detail[:item_payable_amount], total_discount: detail[:item_discount_amount])

              if payment_gateway_mode_association.present?

                convenience_charges_detail = payment_gateway_mode_association.tax_on_transaction_charges(tax_details[:total_payable_amount])

                convenience_charges = convenience_charges_detail[:total_transaction_charges]

                tax_details.merge!(convenience_charges_detail)

              else

                convenience_charges = ((tax_details[:total_payable_amount] * detail[:gateway_tax_percentage]).to_f / 100).rnd

              end

              tax_details[:convenience_charges] = convenience_charges

            rescue => e
              Rollbar.error(e)
            end
          else
            logger.info("EventOrder: perform_updation: tax_details: #{index}\nTax details cannot be calculated as payable amount for this item is: #{detail[:item_payable_amount] - detail[:item_discount_amount]}")
          end

          # if is_transferred is false means discounted_line_item and item both are same
          if discounted_line_item.id == item.id and not is_transferred

            # Update status, transferred_ref_number, syid, event_seating_category_association_id, seating category id, discount and price to event order line item
            logger.info("Model: EventOrder, Method: perform_updation, Message: event_order_line_item_id: #{item.try(:id)} update (status, transferred_ref_number, syid and event_seating_category_association_id and price, seating_category and discount) error, errors: #{item.errors.full_messages}") unless item.update(sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: category.id, price: category.price, seating_category_id: category.try(:seating_category).try(:id), status: status, transferred_ref_number: transferred_ref_number, discount: discount)

            # Update event registration
            registration = item.event_registration

            # Update status, transferred_ref_number, syid and event_seating_category_association_id and price to event registration
            logger.info("Model: EventOrder, Method: perform_updation, Message: registration id: #{registration.try(:id)} update (status, syid and event_seating_category_association_id) error, errors: #{registration.errors.full_messages}") unless registration.update(sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: category.id, status: status)

            # Update item tax details
            item.update_item_tax_detail(tax_details)

          else

            # Update discount of event order line item
            logger.info("Model: EventOrder, Method: perform_updation, Message: event_order_line_item_id: #{discounted_line_item.try(:id)} update (discount) error, errors: #{discounted_line_item.errors.full_messages}") unless discounted_line_item.update(discount: discount)


            # Update status, transferred_ref_number, syid and event_seating_category_association_id and price to event order line item
            logger.info("Model: EventOrder, Method: perform_updation, Message: event_order_line_item_id: #{item.try(:id)} update (status, transferred_ref_number, syid and event_seating_category_association_id and price) error, errors: #{item.errors.full_messages}") unless item.update(status: status, transferred_ref_number: transferred_ref_number)

            # Update event registration
            registration = item.event_registration

            # Update status, transferred_ref_number, syid and event_seating_category_association_id and price to event registration
            logger.info("Model: EventOrder, Method: perform_updation, Message: registration id: #{registration.try(:id)} update (status, syid and event_seating_category_association_id) error, errors: #{registration.errors.full_messages}") unless registration.update(status: status)

            # Update item tax details
            discounted_line_item.update_item_tax_detail(tax_details)
          end

        rescue => e
          Rollbar.error(e)
        end
      end

      # Calculate total discount for specific event order
      # total_discount = self.event_order_line_items(true).collect{|x| x.discount.to_f}.sum
      # logger.info("Model: EventOrder, Method: perform_updation : Error while updating event order total discount: #{self.errors.full_messages}") unless self.update_column("total_discount", total_discount)

      # Update tax details
      update_event_order_tax_details

    rescue => e
      logger.info("Runtime Exception: #{e.message}")
      Rollbar.error(e)
    end
  end

  def check_dd_transaction
    if self.payment_method == 'Demand draft' and EventOrder.statuses.slice(:dd_received_by_india_admin, :dd_received_by_rc).values.include?(EventOrder.statuses[self.status])
      self.event_order_line_items.each do |item|
        self.event_registrations.create(user_id: self.user_id, event_seating_category_association_id: item.event_seating_category_association_id, sadhak_profile_id: item.sadhak_profile_id, event_id: self.event_id, is_extra_seat: item.is_extra_seat)
      end
      # Send email as payment is done
      self.notify_joining if self.event.try(:notification_service)
    end
  end

  def payble_amount_with_taxes(options = {})
    raise SyException, 'Please provide sadhak profile list with seating category details.' unless options[:sadhak_profiles].present?

    # Assign needed data to local variables
    line_items_ids = (options[:event_order_line_item_ids] || []).map { |x| x.to_i }
    sadhak_profiles = options[:sadhak_profiles]
    parent_event_order_id = options[:parent_event_order_id]

    total_old_amount = 0.0
    total_new_amount = 0.0
    total_old_discount = 0.0
    total_new_discount = 0.0
    old_event_ids = []
    new_event_ids = []
    details = []

    # discount feature_code in progress
    db_sadhaks = SadhakProfile.where(id: sadhak_profiles.collect{|sp| sp[:syid][/-?\d+/].to_i})
    categories = EventSeatingCategoryAssociation.includes(:event).where(id: sadhak_profiles.collect{|s| s[:event_seating_category_association_id]})

    # Run in case of transfer of event order
    if parent_event_order_id.present?
      # Verify parent event order id
      raise SyException, "Parent event order id doesn't match." unless TransferredEventOrder.find_by(child_event_order_id: self.id, parent_event_order_id: parent_event_order_id).present?

      # Find parent event order
      @parent_eo = EventOrder.includes(:event_registrations, :event_order_line_items).find_by_id(parent_event_order_id)

      # Raise if no parent registrations found
      raise SyException, 'No event registrations found associated with parent event order. So transfer is not possible.' unless @parent_eo.try(:event_registrations).present?

      # Update line item ids
      line_items_ids = sadhak_profiles.collect{|sp| sp[:event_order_line_item_id]}

      # for updating transfered line item discount
      transferred_line_items = self.event_order_line_items.where(sadhak_profile_id: sadhak_profiles.collect{|sp| sp[:syid][/-?\d+/].to_i})
    end

    # Raise error if no line item ids found
    raise SyException, 'No line items found.' unless line_items_ids.present?

    # Run in case of upgrade and normal payment of event order
    EventOrderLineItem.includes(:event_seating_category_association, :event_registration, {event_order: [:event]}, :sadhak_profile ,{event: [{discount_plan: [:events]}]}).where(id: line_items_ids).each do |item|

      # To reset discount variables locally
      old_discount_per_sadhak = 0.0
      new_discount_per_sadhak = 0.0

      # Compute old price using existing seating category
      total_old_amount += item.try(:event_seating_category_association).try(:price).to_f
      old_event_ids.push(item.try(:event_registration).try(:event_id))

      # Find sadhak profile object
      sp = sadhak_profiles.find{|s| s[:event_order_line_item_id].to_i == item.id}

      # Raise error if no sadhak profile object found
      raise SyException, "Please provide seating category details for SYID: SY#{item.sadhak_profile_id}." unless sp.present?

      db_sadhak = db_sadhaks.find{|s| s.id == sp[:syid][/-?\d+/].to_i}
      # Raise error if no sadhak profile object found
      raise SyException, "No sadhak profile found with SYID: SY#{sp[:syid]}." unless db_sadhak.present?

      # Find new category
      category = categories.find{|c| c.id == sp[:event_seating_category_association_id].to_i}
      raise SyException, "Seating category association not found with id: #{sp[:event_seating_category_association_id]}" unless category.present?
      total_new_amount += category.try(:price).to_f
      new_event_ids.push(category.try(:event_id))

      # Logic to calculate old discount start
      cloned_sp = sp.clone
      cloned_sp[:event_seating_category_association_id] = item.try(:event_seating_category_association_id)
      cloned_sp[:syid] = item.try(:sadhak_profile_id)

      old_discount_per_sadhak = item.event.calculate_discount([cloned_sp]) if (item.sadhak_profile.event_ids & (item.event.discount_plan.try(:event_ids)|| [])).present?
      total_old_discount += old_discount_per_sadhak
      # Logic to calculate old discount ends

      # Logic to calculate new discount start
      new_discount_per_sadhak = category.event.calculate_discount([sp]) if (db_sadhak.event_ids & (self.event.discount_plan.try(:event_ids) || [])).present?
      total_new_discount += new_discount_per_sadhak

      if parent_event_order_id.present?
        line_item = transferred_line_items.find{|s| s.sadhak_profile_id == db_sadhak.id}
      else
        line_item = item
      end

      sp[:discounted_line_item_id] = item.id
      sp[:discount] = new_discount_per_sadhak
      details.push(sp)
    end

    # Decision based on computed amounts and discounts (old and new) if both are equal i.e normal event order payment, if total_new_amount is greater than old amount i.e transferred or upgrade case
    if total_new_amount - total_new_discount == total_old_amount - total_old_discount
      db_payable_amount = total_new_amount
      total_discount_amount = total_new_discount
    elsif total_new_amount - total_new_discount > total_old_amount - total_old_discount
      db_payable_amount = total_new_amount - total_old_amount
      total_discount_amount = total_new_discount - total_old_discount
    else
      raise SyException, 'Unable to compute payable amount.'
    end

    amount_details = {original_amount: db_payable_amount, total_discount: total_discount_amount}

    total_payble_amount_with_tax = self.event.calculate_tax_amount(amount_details)

    convenience_charges = 0

    if payment_gateway_mode_association = PaymentGatewayModeAssociation.find_by_id(options[:payment_gateway_mode_association_id])

      convenience_charges_detail = payment_gateway_mode_association.tax_on_transaction_charges(total_payble_amount_with_tax[:total_payable_amount])

      convenience_charges = convenience_charges_detail[:total_transaction_charges]

      total_payble_amount_with_tax.merge!(convenience_charges_detail)

    elsif options[:config_id].present? && options[:method].present?

      gateway = TransferredEventOrder.gateways.find{|g| g[:symbol] == options[:method]} || {}

      gateway_tax_percentage = gateway[:config_model].try(:camelize).try(:constantize).try(:send, :find_by_id, options[:config_id]).try(:tax_amount).to_f

      convenience_charges = ((total_payble_amount_with_tax[:total_payable_amount] * gateway_tax_percentage).to_f / 100).rnd

    end

    db_payable_amount = total_payble_amount_with_tax[:total_payable_amount] + convenience_charges

    total_payble_amount_with_tax[:convenience_charges] = convenience_charges

    total_payble_amount_with_tax[:total_payable_amount] = db_payable_amount.rnd

    self.update_column('tax_details', total_payble_amount_with_tax)

    total_payble_amount_with_tax
  end

# TO send emails to approver and logistic email , in case of pre_approval event
  def pre_approval_application_details
    begin
      if self.event.pre_approval_required? and self.event.approver_email.present?
        sadhak_ids = self.event_order_line_items.pluck(:sadhak_profile_id)
        recipients = self.event.approver_email.to_s.split(',')
        logistic_email = self.event.logistic_email.to_s.split(',')
        subject = "Application #{self.reg_ref_number} request for event #{self.event.event_name}-#{self.event_id}, SYID: #{(sadhak_ids || []).join(',')}."
        if sadhak_ids.present? and sadhak_ids.count > 0
          profiles = SadhakProfile.where(id: sadhak_ids)
          sadhak_details = get_sadhak_details(profiles)
          if sadhak_details.collect{|sd| sd[:application_rejected_events_of_same_type_count]}.reduce(:+) > 0
            recipients = logistic_email
            subject = 'Reject Re-Apply ' + subject
          end
        end
        from = GetSenderEmail.call(self.event)
        template = 'pre_approval_registration_details'
        template = 'special_event_pre_approval_registration_details' if event.is_ashram_residential_shivir?
        approve_token = [self.reg_ref_number, Time.zone.now.to_i.to_s, 'approve'].join(',').encrypt
        reject_token = [self.reg_ref_number, Time.zone.now.to_i.to_s, 'reject'].join(',').encrypt
        ApplicationMailer.send_email(from: from, recipients: recipients, reply_to: logistic_email.first, subject: subject, template: template, sadhak_details: sadhak_details, event: self.event, approve_token: approve_token, reject_token: reject_token).deliver
        return true
      end
    rescue => e
      logger.error("Exception: EventOrder:pre_approval_application_details: #{e.message}")
      Rollbar.error(e)
    end
  end

# To get sadhak profile details object includeing fullname,Address,Date of birth, Marital Status  (and any remaining part of basic info) Name of Guru, Other Spiritual Associations,Past Shivirs recorded in portal, Past Shivirs self-reported, Professional details
  def get_sadhak_details(sadhak_profiles)
    sadhak_full_details = []

    # Collect all past rejected applications
    past_applications = EventOrderLineItem.joins(:event_order, :event).where(event_orders: {status:  EventOrder.statuses['rejected']}, events: {pre_approval_required: true}).order('event_order_line_items.created_at DESC').includes({event_order: [{event: [:event_type]}]}).uniq

    sadhak_profiles.each do |sadhak|
      sadhak_data = {}
      sadhak_data[:fullname] = sadhak.full_name
      sadhak_data[:syid] = sadhak.syid
      sadhak_data[:date_of_birth] = sadhak.date_of_birth
      sadhak_data[:gender] = sadhak.gender
      sadhak_data[:marital_status] = sadhak.marital_status
      sadhak_data[:mobile] = sadhak.mobile
      sadhak_data[:email] = sadhak.email
      sadhak_data[:guru_name] = sadhak.name_of_guru
      sadhak_data[:spiritual_org_name] = sadhak.spiritual_org_name
      sadhak_data[:address] = sadhak.address
      sadhak_data[:advance_profile] = sadhak.advance_profile
      sadhak_data[:other_spiritual_associations] = sadhak.other_spiritual_associations
      sadhak_data[:professional_detail] = sadhak.professional_detail
      sadhak_data[:medical_practitioners_profile] = self.event.event_type.name == 'Doctors Event'.downcase ? sadhak.medical_practitioners_profile : ''
      sadhak_data[:shivir_reported_by_sadhak] = sadhak.sadhak_profile_attended_shivirs
      sadhak_data[:shivir_attended_by_record] = sadhak.events
      sadhak_data[:application_rejected_events] = past_applications.select{|pa| pa.sadhak_profile_id == sadhak.id}.collect{|item| {event_name: item.event.event_name_with_location, event_date: item.event.event_date, event_type: item.event.event_type.name} }
      sadhak_data[:application_rejected_events_of_same_type_count] = past_applications.select{|pa| pa.sadhak_profile_id == sadhak.id and pa.event.event_type_id == self.event.event_type_id}.size

      # Special case for 'Ashram Residential Shivirs'
      if self.event.is_ashram_residential_shivir?

        # Get special event sadhak profile info
        line_item = self.event_order_line_items.find{|item| item.sadhak_profile_id == sadhak.id}

        sadhak_data[:special_event_sadhak_profile_other_info] = line_item.special_event_sadhak_profile_other_info

        sy_club_member = sadhak.forum_memberships.first

        sadhak_data[:forum_name] = sy_club_member.try(:sy_club).try(:name)

        sadhak_data[:forum_address] = sy_club_member.try(:sy_club).try(:address)

        sadhak_data[:membership_since] = sy_club_member.try(:event_registration).try(:created_at).try(:strftime, '%d-%M-%Y')

        sadhak_data[:designation_in_forum] = if sadhak.sy_club_sadhak_profile_associations.any? then
                                               sadhak.sy_club_sadhak_profile_associations.first.sy_club_user_role.role_name.titleize
                                             else
                                               sy_club_member.present? ? 'Member' : ''
                                             end

        sadhak_data[:total_shivirs_attended] = sadhak.events.count

        sadhak_data[:attended_babaji_shivirs] = sadhak.events.select{|event| event.graced_by == 'Baba ji'}.size

        sadhak_data[:attended_ishanji_shivirs] = sadhak.events.select{|event| event.graced_by == 'Ishan ji'}.size

        sadhak_data[:attended_online_shivirs] = sadhak.events.select{|event| event.graced_by == 'Subtle presence of Babaji'}.size

      end

      sadhak_full_details.push(sadhak_data)
    end
    sadhak_full_details
  end

  def notify_sadhak_about_payment_failure(event_order_line_items_ids = [])
    begin
      # Collect all line items that are modified
      line_items = EventOrderLineItem.where(id: event_order_line_items_ids).includes({sadhak_profile: [:user]}, {event_order: [:event]})

      raise SyException, 'EventOrder: notify_sadhak_about_payment_failure, Message: Event order line items not found.' unless line_items.present?

      from = GetSenderEmail.call(self.event)

      # Process each item for failure payment
      line_items.each_with_index do |item, index|

        sadhak_profile = item.sadhak_profile

        raise SyException, "Sadhak Profile does not exist. SY#{item.sadhak_profile_id}." unless sadhak_profile.present?

        # Send failed transaction details on mobile
        if sadhak_profile.present?
          message = "NMS #{sadhak_profile.full_name.try(:titleize)}-#{sadhak_profile.syid}\nYour payment for Ref no: #{self.reg_ref_number} on shivir #{self.event.event_name} failed. Please try again."
          sadhak_profile.send_sms_to_sadhak(message)
        end

        # Send failed transaction detail on email
        begin
          # Try to get vaild email form sadhak model, user model
          email = sadhak_profile.email.to_s.is_valid_email? ? sadhak_profile.email : nil
          email = if email.nil? then
                    sadhak_profile.user.try(:email).to_s.is_valid_email? ? sadhak_profile.user.try(:email) : nil
                  else
                    email
                  end

          if email.present?
            ApplicationMailer.send_email(from: from, recipients: email, subject: "Payment failed for shivir: #{self.event.try(:event_name)}, reference number: #{self.reg_ref_number}", template: 'notify_payment_failure', line_items: [item], event_order: self).deliver
          end
        rescue => e
          Rails.logger.info("Error occured while sending failed payment message for SYID: #{sadhak_profile.try(:syid)}, error: #{e.message}")
          Rollbar.error(e)
        end
      end

      begin
        # Send failed message to guest email
        if self.guest_email.is_valid_email?
          ApplicationMailer.send_email(from: from, recipients: self.guest_email, subject: "Payment failed for shivir: #{self.event.try(:event_name)}, reference number: #{self.reg_ref_number}", template: 'notify_payment_failure', line_items: line_items, event_order: self).deliver
        end
      rescue => e
        Rails.logger.info("Runtime Exception: #{e.message}")
        Rollbar.error(e)
      end

    rescue SyException => e
      Rails.logger.info("Manual Exception: #{e.message}")
    rescue => e
      Rails.logger.info("Runtime Exception: #{e.message}")
      Rollbar.error(e)
    end
  end
  handle_asynchronously :notify_sadhak_about_payment_failure

  def do_generate_event_orders_data(event_orders, event)
    currency_code = event.pay_in_usd? ? 'USD' : event.try(:address).try(:country_currency_code)
    country_name = event.try(:address).try(:country_name)
    state_name = event.try(:address).try(:state_name)
    city_name = event.try(:address).try(:city_name)

    header = %W(SYIDS FIRST_NAMES LAST_NAMES EMAILS MOBILES GUEST_EMAIL REG_REF_NO COUNTRY STATE CITY TOTAL_AMOUNT(#{currency_code}) TOTAL_DISCOUNT(#{currency_code}) PAYMENT_STATUS TRANSACTION_DATE TRANSACTION_ID TRANSACTION_TYPE TRANSACTION_METHOD SADHAK_ADDRESS)
    rows = []
    (event_orders || []).each_with_index do |eo, index|
      begin
        syids = []
        first_names = []
        last_names = []
        emails = []
        mobiles = []
        gateway = TransferredEventOrder.gateways.find{|g| g[:payment_method] == eo.payment_method.to_s} || {}
        transaction_type = gateway[:gateway_type] == 'offline' ? gateway[:symbol].try(:titleize) : gateway[:gateway_type].try(:titleize)
        transaction_date = eo.try(:send, "#{gateway[:model].try(:underscore).try(:pluralize)}").try(:last).try(:created_at) if gateway.present?

        sadhak = nil

        # Push sadhak details in respective arrays
        eo.sadhak_profiles.each do |s|
          syids.push(s.syid.to_s)
          first_names.push(s.first_name.to_s)
          last_names.push(s.last_name.to_s)
          emails.push(s.email.to_s) if $current_user.try(:super_admin?)
          mobiles.push(s.mobile.to_s) if $current_user.try(:super_admin?)
          sadhak = s if (sadhak.nil? and s.address.present?)
        end

        if sadhak.present? and sadhak.address.present?
          city = sadhak.address.city_name.present? ? sadhak.address.city_name : ''
          state = sadhak.address.state_name.present? ? sadhak.address.state_name : ''
          country = sadhak.address.country_name.present? ? sadhak.address.country_name : ''
          address = ("#{sadhak.address.street_address} #{city} #{state} #{country}").split(" ").join(" ")
        end

        rows.push([syids.join(','), first_names.join(','), last_names.join(','), emails.join(','), mobiles.join(','), eo.guest_email.to_s, eo.reg_ref_number, country_name, state_name, city_name, ('%.2f' % eo.total_amount.to_f), ('%.2f' % eo.total_discount.to_f), eo.status, transaction_date.try(:strftime, ('%F %T')).to_s, eo.transaction_id, transaction_type, eo.payment_method, $current_user.try(:super_admin?) ? address : ""])
      rescue Exception => e
        Rails.logger.info("Exception occured: EventOrder: do_generate_event_orders_data, error: #{e.message} , event order id: #{eo.try(:id)}")
        raise e.message
      end
    end

    return {rows: rows, header: header}
  end

  def update_event_order_tax_details
    begin
      tax_details = self.tax_details.deep_symbolize_keys
      tax_details[:created_at] = DateTime.now.to_s
      total_tax_details = self.total_tax_details || []
      total_tax_details.push(tax_details.as_json)

      # Update order tax detail
      order_tax_detail = (self.order_tax_detail || {total_tax_paid: 0.0, tax_breakup: [], total_convenience_charges: 0.0, tax_breakup_on_convenience_charges: []}).deep_symbolize_keys
      order_tax_detail[:total_tax_paid] = (order_tax_detail[:total_tax_paid].rnd + tax_details[:total_tax_applied].rnd)
      order_tax_detail[:total_convenience_charges] = (order_tax_detail[:total_convenience_charges].rnd + tax_details[:convenience_charges].rnd)

      order_tax_detail[:tax_breakup] ||= []
      order_tax_detail[:tax_breakup_on_convenience_charges] ||= []

      # Update or push tax breakup
      (tax_details[:tax_breakup] || []).each do |breakup|
        # Find existing tax break up
        found = (order_tax_detail[:tax_breakup] || []).find{ |t| t[:tax_name].present? and t[:tax_name].downcase == breakup[:tax_name].downcase }

        # If found
        if found.present?
          found[:amount] += breakup[:amount].rnd
        else
          order_tax_detail[:tax_breakup].push(breakup)
        end
      end

      # Update or push convenience charges tax breakup
      (tax_details[:tax_breakup_on_convenience_charges] || []).each do |breakup|

        # Find existing convenience charges tax break up
        found = (order_tax_detail[:tax_breakup_on_convenience_charges] || []).find{ |t| t[:tax_name].present? and t[:tax_name].downcase == breakup[:tax_name].downcase }

        # If found
        if found.present?
          found[:amount] += breakup[:amount].rnd
        else
          order_tax_detail[:tax_breakup_on_convenience_charges].push(breakup)
        end
      end

      # Update event order with updated tax details
      Rails.logger.info("EventOrder: update_event_order_tax_details: Some error ocuured while updating tax details in event order: #{self.id}") unless self.update_columns(order_tax_detail: order_tax_detail, total_tax_details: total_tax_details)

    rescue => e
      Rails.logger.info("EventOrder: update_event_order_tax_details: Exception occured: #{e.message}")
      Rollbar.error(e)
    end
    Rails.logger.info('EventOrder: update_event_order_tax_details: End')
  end

  # Create default total tax details to event order
  def create_order_tax_details
    self.order_tax_detail = {total_tax_paid: 0.0, tax_breakup: [], total_convenience_charges: 0.0, tax_breakup_on_convenience_charges: []}
  end

  def send_pre_approval_sms
    # SMS sending on pre-approval application approved
    begin

      ashram_residential_message = "REPORTING DAY : #{(event.event_start_date.to_date - 1.day).strftime('%A, %d %B %Y')}\nREPORTING TIME: 1pm (Latest by 3pm as #{(event.event_start_date.to_date - 1.day).strftime('%A')} evening 5pm onwards we have the oath ceremony)\nSHIVIR BEGINS FROM #{(event.event_start_date.to_date).strftime('%A')} TO #{(event.event_end_date.to_date).strftime('%A')} (6 am to 7 pm). WE ALSO WANT TO INFORM THAT DUE TO FOG IN WINTERS CAN WE START THE SESSION AT 7am.\nDEPARTURE : On #{event.event_end_date.to_date.strftime('%A, %d %B %Y')} after 10 am." if event.is_ashram_residential_shivir?

      sadhak_profiles.each do |sadhak_profile|
        # Generate SMS
        message = "Namah Shivay #{sadhak_profile.try(:first_name).try(:titleize)},\nYour application with Reference No: #{reg_ref_number} for event - #{event.try(:event_name_with_location).to_s} approved by Ashram.\n#{ashram_residential_message}"

        # Send sms to sadhak
        sadhak_profile.send_sms_to_sadhak(message)
      end
    rescue => e
      logger.info("Runtime Exception: send_pre_approval_sms - error: #{e.message}")
      Rollbar.error(e)
    end
  end

  # method to  validate and update entry before payment
  def update_before_pay(sadhak_profiles)
    is_sadhak_profile_touched = false
    valid_profiles_to_register = []
    seating_categories_requested = []
    if self.event.pre_approval_required?
      updated_line_item_ids = sadhak_profiles.collect{|s| s.event_order_line_item_id}.map { |e| e.to_i  }
      original_line_items =  self.event_order_line_items.select{|old| not updated_line_item_ids.include?(old.id)}
      updated_line_items = EventOrderLineItem.where(id: updated_line_item_ids)
      original_sadhak_ids = original_line_items.collect{|old| old.sadhak_profile_id}
      updated_sadhak_profiles = SadhakProfile.where(id: sadhak_profiles.collect{|s| s[:syid]})

      # Blocker: if sadhak is updating SYID and new SYID found on same event against other application
      event_order_ids = self.event.event_orders.order('created_at DESC').pluck(:id)
      existing_line_items = EventOrderLineItem.includes(:event_order).where(event_order_id: event_order_ids, status: EventOrderLineItem.valid_line_item_statuses).order('created_at DESC')

      sadhak_profiles.each do |sp|

        touched_columns = []

        line_item = updated_line_items.find{|u| u.id == sp.event_order_line_item_id.to_i}

        raise SyException, "SYID: SY#{sp.syid}, Sadhak Profile line item not found." unless line_item.present?

        sadhak_profile = updated_sadhak_profiles.find{|s| s.id == sp.syid.to_i}

        raise SyException, "SYID: SY#{sp.syid}, Sadhak Profile not found." unless sadhak_profile.present?

        raise SyException, "SYID: SY#{sp.syid}, Sadhak Profile already requested a registration against same application." if line_item.sadhak_profile_id != sp.syid.to_i and original_sadhak_ids.include?(sp.syid.to_i)

        if line_item.sadhak_profile_id != sp.syid.to_i
          touched_columns.push('sadhak_profile_id')
          found = existing_line_items.find{ |_item| _item.sadhak_profile_id == sp.syid.to_i }
          raise SyException, "SYID: SY#{sp.syid}, Another registration request with ref number (#{found.event_order.reg_ref_number}) already found." if found.present?
        end

        sp[:touched_columns] = touched_columns

        raise SyException, "Name: #{sadhak_profile.first_name} and SYID: #{sadhak_profile.syid}, Sadhak Profile already registered for this event." if sadhak_profile.events.include?(self.event)

        # To check whether to allow seat for this request or its just name change.
        scr = seating_categories_requested.find {|sc| sc[:id] == sp.event_seating_category_association_id}
        if line_item.event_seating_category_association_id != sp.event_seating_category_association_id.to_i and line_item.sadhak_profile_id == sp.syid.to_i
          s_occupied = 1
        elsif line_item.event_seating_category_association_id == sp.event_seating_category_association_id.to_i and line_item.sadhak_profile_id != sp.syid.to_i
          s_occupied = 0
        elsif line_item.event_seating_category_association_id != sp.event_seating_category_association_id.to_i and line_item.sadhak_profile_id != sp.syid.to_i
          s_occupied = 1
        end
        if scr.nil?
          seating_categories_requested.push({id:  sp['event_seating_category_association_id'], seats_requested: s_occupied, sadhaks: [sadhak_profile.id]})
        else
          scr[:seats_requested] += s_occupied
          scr[:sadhaks].push(sadhak_profile.id)
        end

        # Assigned false valiue to extra seat to avoid prooblem is case of non-logged-in user or non-admin users
        sp[:is_extra_seat] = false
        valid_profiles_to_register.push(sp)
      end

      # Update requested seating category count origin
      original_line_items.each do |item|
        # sp = item.sadhak_profile
        scr = seating_categories_requested.find {|sc| sc[:id].to_i == item.event_seating_category_association_id}
        if scr.nil?
          seating_categories_requested.push({id:  item.event_seating_category_association_id.to_s, seats_requested: 1, sadhaks: [item.sadhak_profile_id]})
        else
          scr[:seats_requested] += 1
          scr[:sadhaks].push(item.sadhak_profile_id)
        end
      end

      seating_categories_requested.each do |scr|
        event_seating_category_association_model = EventSeatingCategoryAssociation.find(scr[:id]
          )

        #check if EventSeatingCategoryAssociation found` or check if EventSeatingCategoryAssociation belongs to the requested event
        raise SyException, "Seating category #{scr.category_name} does not belong to requested event" unless event_seating_category_association_model.present? or event_seating_category_association_model.event != self.event

        # TO check whenther some of the profile already apply for this seating category and number of seats requested are available in this category are available or not
        # seats_reserved = event_seating_category_association_model.seating_capacity
        # if seats_reserved.present?
          s_capacity = event_seating_category_association_model.seating_capacity.to_i
          raise SyException, "Not enough seats available in #{event_seating_category_association_model.seating_category.category_name} category" if scr[:seats_requested].to_i > s_capacity.to_i or s_capacity.to_i <= 0 #and line_item.sadhak_profile_id != sp.syid.to_i
        # end
        #check if number of seats requested are available in this category
        seats_occupied = self.event.event_registrations.where(:event_seating_category_association_id  => scr[:id], :status => [nil, EventRegistration.statuses['updated']]).count
        total_seats = event_seating_category_association_model.seating_capacity
        seats_available = total_seats - seats_occupied

        if $current_user.present? and ($current_user.super_admin? or $current_user.event_admin? or $current_user.india_admin?)
          seats_available < scr[:seats_requested].to_i
          scr[:sadhaks].each do |sadhak_id|
            sp = valid_profiles_to_register.find {|s| s[:syid].to_i == sadhak_id}
            if seats_available < 1  #sp[:is_extra_seat] == seats_available < 1
              sp[:is_extra_seat] = true if sp.present?
              seats_available -= 1
            else
              sp[:is_extra_seat] = false if sp.present?
            end
          end
        else
          #check if requested number of seats are available
          if seats_available < scr[:seats_requested].to_i
            raise SyException, "No seats available in #{event_seating_category_association_model.seating_category.category_name} category"  if seats_available <= 0
            raise SyException, "Only 1 seat is available in  #{event_seating_category_association_model.seating_category.category_name} category" if seats_available == 1
            raise SyException, "Only #{seats_available} seat is available in  #{event_seating_category_association_model.seating_category.category_name} category"
          end
        end
      end
      ApplicationRecord.transaction do
        # To update individual item
        updated_line_items.each do |uli|
          sp = sadhak_profiles.find{|s| s[:event_order_line_item_id].to_i == uli.id}
          raise SyException, uli.errors.full_messages.first unless uli.update(sadhak_profile_id: sp.syid, event_seating_category_association_id: sp.event_seating_category_association_id, is_extra_seat: sp.is_extra_seat)
        end
        if sadhak_profiles.collect{|s| s[:touched_columns]}.flatten.include?('sadhak_profile_id')
          is_sadhak_profile_touched = true
          self.update(status: EventOrder.statuses['pending'])
          self.delay.pre_approval_application_details rescue "Error while calling method to send details of pro_approval event's registration"
        end
      end
    end
    is_sadhak_profile_touched
  end

  # Mapper to map statuses on template
  def self.template_status_mapper
    ActiveSupport::HashWithIndifferentAccess.new(
      cancelled: 'Cancellation Refunded',
      transferred: 'Shivir Changed',
      updated: 'Updated',
      success: 'Success',
      cancelled_refunded: 'Cancellation Refunded',
      cancelled_refund_pending: 'Cancellation-Refund Pending',
      upgraded: 'Category Upgraded',
      downgraded: 'Category Downgraded',
      name_changed: 'Name Changed',
      shivir_changed: 'Shivir Changed',
      downgrade_requested: 'Category Downgrade Requested',
      shivir_change_requested: 'Shivir Change Requested',
      name_change_requested: 'Name Change Requested',
      upgrade_requested: 'Category Upgrade Requested',
      expired: 'Expired',
      renewed: 'Renewed'
    )
  end

  # Payment status Mapper
  def self.payment_status_mapper
    ActiveSupport::HashWithIndifferentAccess.new(
      pending: 'Under Processing',
      success: 'Received',
      approved: 'Approved',
      failure: 'Failed',
      failed: 'Failed'
    )
  end

  def notify_joining
    begin

      # Boolean used to differentiate fresh order or updated order
      is_fresh_order = true

      # Find gateway used for payment
      gateway = TransferredEventOrder.gateways.find{|g| g[:payment_method] == self.payment_method}

      # Find payment object
      payment = gateway[:model].constantize.where("#{gateway[:transaction_id]}" => self.transaction_id, event_order_id: self.id).last

      # Find transaction log
      search_in_statuses = TransactionLog.statuses.slice(:success).values
      search_in_statuses << TransactionLog.statuses['pending'] if self.payment_method == 'Demand draft'
      gateway_transaction_id = payment.send("#{gateway[:transaction_id]}")
      gateway_transaction_id = payment.charge_id if self.payment_method == 'Stripe Payment'
      transaction_log = self.transaction_logs.where(gateway_transaction_id: gateway_transaction_id, status: search_in_statuses, transaction_type: TransactionLog.transaction_types[:pay], gateway_name: gateway[:symbol]).last

      # Get details that holds all information about payment
      details = (transaction_log.try(:request_params) || {}).deep_symbolize_keys[:details] || []

      # Compute fresh order or updated order
      if details.present?
        _statuses = details.collect{|d| d[:status]}.uniq
        is_fresh_order = (EventOrderLineItem.statuses.except(:success, :expired, :renewed).values & _statuses).size == 0
      end

      # Get line items for which payment made
      line_item_ids = details.collect{|sp| sp[:event_order_line_item_id]}

      # In case there is details missing then get line items from event order
      line_items = line_item_ids.present? ? EventOrderLineItem.where(id: line_item_ids) : self.event_order_line_items

      # Get sadhak profiles
      sadhak_profiles = line_items.collect{|li| li.try(:sadhak_profile)}

      # Get Syids
      syids = sadhak_profiles.collect{|s| s.syid}.join(',')

      # Get sadhak email
      cc = sadhak_profiles.collect{|s| s.email}

      # Get sender email
      from = GetSenderEmail.call(self.event)

      # Recipient
      recipients = [self.guest_email]

      # Send a copy to support
      support_emails = ENV['DEVELOPMENT_RESP'].extract_valid_emails

      if ENV['ENVIRONMENT'] == 'production'
        support_emails = self.event.is_in_india? ? ['registration@shivyogindia.com'] : ['info@absclp.com']
      end

      # Update Recipients if registered by any admin
      if self.user.present? and (self.user.super_admin? || self.user.india_admin? || self.user.event_admin? || self.user.club_admin?)
        recipients = support_emails
      end

      # Fire email only if event order success and payment success or payment method is dd and dd received by RC or Ashram or India Admin
      if EventOrder.statuses.slice(:success, :dd_received_by_ashram, :dd_received_by_india_admin, :dd_received_by_rc).values.include?(EventOrder.statuses[self.status]) and (payment.class.statuses[payment.status] == gateway[:success] or self.payment_method == 'Demand draft')

        # Send email is order is related to forum
        if self.try(:sy_club_id).present?
          # Send forum joining email to sadhaks and guest email

          ApplicationMailer.send_email(from: from, recipients: recipients, cc: cc, template: 'event_forum_payment_confirmation_email', subject: "Forum (#{self.try(:sy_club).try(:name)}) registration(s) successful ##{syids}", data: payment).deliver

          board_member_emails = self.try(:sy_club).try(:board_member_emails)
          ApplicationMailer.send_email(from: from, recipients: board_member_emails, template: 'event_forum_payment_confirmation_email', subject: "Forum (#{self.try(:sy_club).try(:name)}) registration(s) successful ##{syids}", data: payment, is_board_members: true).deliver if board_member_emails.present?
        else

          # Send event joining email to sadhaks and guest email
          subject_prefix = 'Registration(s) update successful'
          subject_prefix = 'Registration(s) successful' if is_fresh_order

          ApplicationMailer.send_email(from: from, recipients: recipients, cc: cc, template: 'event_order_confirmation', subject: " #{subject_prefix} ##{self.reg_ref_number} ##{syids} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", payment: payment, gateway: gateway, event_order: self, line_items: line_items, is_fresh_order: is_fresh_order).deliver

          # Disable for now : As per request on email Fwd: to remove entry cards details
          # send_entry_cards(event_order_line_item_ids: line_items.collect{|item| item.id})

        end
      end
    rescue => e
      Rails.logger.info("Exception in event order: notify joining: #{e.message}")
      Rollbar.error(e)
    end
    errors.empty?
  end
  handle_asynchronously :notify_joining

  def send_free_event_registration_confirmation

    from = GetSenderEmail.call(event)

    recipients = sadhak_profiles.pluck(:email)
    recipients << guest_email
    recipients = recipients.extract_valid_emails

    ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Registration confirmation for event #{self.event.event_name}", template: 'free_event_reg_confirmation.html.erb', event_order: self).deliver if recipients.any?

    # Disable for now : As per request on email Fwd: to remove entry cards details
    # send_entry_cards(form: from)

  end
  handle_asynchronously :send_free_event_registration_confirmation

  def send_entry_cards(options = {})

    if self.event.shivir_card_enabled? && self.event.event_start_date.present? && self.event.event_start_date >= (Date.today - 1.day)

      options = options.deep_symbolize_keys

      options[:template] ||= 'event_order_entry_card'

      options[:recipients] ||= self.guest_email

      options[:event_order_line_item_ids] ||= self.event_order_line_item_ids

      line_items = EventOrderLineItem.where(id: options[:event_order_line_item_ids])

      options[:from] ||= GetSenderEmail.call(self.event)

      # Hold attachments for each sadhak
      attachments = {}
      shivir_cards_errors = []
      syids = []
      cc = []

      # Create entry cards for all sadhaks
      line_items.each do |item|
        sadhak_profile = item.sadhak_profile
        syids << sadhak_profile.syid
        cc << sadhak_profile.email
        begin
          card = sadhak_profile.generate_shivir_card(self.reg_ref_number)
          attachments["#{sadhak_profile.syid.downcase}_registration_card_event_#{self.event_id}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.pdf"] = card
          sadhak_profile.delay.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nYour entry card is available for download from your SYID profile and the same has been sent on email #{sadhak_profile.email || recipients.join(',')}")
        rescue Exception => e
          shivir_cards_errors << {sadhak_profile_id: sadhak_profile.id, message: e.message}
        end
      end

      options[:subject] ||= "Shivir Cards ##{self.reg_ref_number} ##{syids.join(',')} ##{self.event.event_name}"

      options = options.merge({event_order: self, shivir_cards_errors: shivir_cards_errors, line_items: line_items, cc: cc, attachments: attachments})

      ApplicationMailer.send_email(options).deliver
    end
  end


  def generate_event_order_slug
    "#{SecureRandom.uuid}-#{SecureRandom.hex(3)}"
  end

  def should_generate_new_friendly_id?
    new_record? || slug.blank?
  end

  def pay_or_refund(options = {})

    result = {
      total_old_price: 0.0,
      total_old_discount: 0.0,
      total_new_price: 0.0,
      total_new_discount: 0.0,
      net_result: 0.0,
      pay: false,
      refund: false,
      is_transfer: options[:event_id].to_i != event_id,
      old_details: [],
      new_details: [],
      touched_event_order_line_items: []
    }

    old_event_order_line_items = EventOrderLineItem.where(id: options[:sadhak_profiles].pluck(:event_order_line_item_id)).includes(:event_seating_category_association)
    raise "Selected Sadhak Profiles Not found." if old_event_order_line_items.blank?

    new_sadhak_profiles = SadhakProfile.where(id: options[:sadhak_profiles].pluck(:sadhak_profile_id))
    raise "Sadhak profiles not found." unless new_sadhak_profiles.present?

    new_event_seating_category_associations = EventSeatingCategoryAssociation.where(id: options[:sadhak_profiles].pluck(:event_seating_category_association_id)).includes(:event)

    new_event = result[:is_transfer] ? Event.find(options[:event_id]) : event

    event_discount_plan = new_event.discount_plan

    seating_categories_requested = []
    seating_categories_released = {}

    options[:sadhak_profiles].each do |sadhak_profile|

      new_detail = {touched_columns: []}
      old_detail = {touched_columns: []}

      new_sadhak_profile = new_sadhak_profiles.find{|sp| sp.id == sadhak_profile[:sadhak_profile_id].to_i}
      raise "No provided Sadhak Profile found in database." if new_sadhak_profile.blank?

      old_event_order_line_item = old_event_order_line_items.find{|i| i.id == sadhak_profile[:event_order_line_item_id].to_i }
      raise "No provided Event Order Line Item found in database." if old_event_order_line_item.blank?

      new_event_seating_category_association = new_event_seating_category_associations.find{ |sc| sc.id == sadhak_profile[:event_seating_category_association_id].to_i }
      raise "No provided Seating Category found in database." if new_event_seating_category_association.blank?

      scr = seating_categories_requested.find {|sc| sc[:id] == new_event_seating_category_association.id }

      scr.blank? ? seating_categories_requested.push({ id: new_event_seating_category_association.id, seats_requested: 1 }) : scr[:seats_requested] += 1

      new_detail[:sadhak_profile_id] = new_sadhak_profile.id
      new_detail[:full_name] = new_sadhak_profile.full_name
      new_detail[:syid] = new_sadhak_profile.syid
      new_detail[:seating_category] = new_event_seating_category_association.category_name
      new_detail[:price] = "#{new_event.currency_code} #{new_event_seating_category_association.price.rnd}"
      new_detail[:discount] = ((new_event_seating_category_association.price.rnd * event_discount_plan.discount_amount.rnd) /100).rnd if event_discount_plan.present? && (new_sadhak_profile.events & event_discount_plan.events).present? && event_discount_plan.try(:percentage?)
      new_detail[:event_order_line_item_id] = old_event_order_line_item.id
      new_detail[:event_seating_category_association_id] = new_event_seating_category_association.id

      result[:total_new_discount] += new_detail[:discount].rnd

      new_detail[:discount] = "#{new_event.currency_code} #{new_detail[:discount].rnd}"

      result[:total_new_price] += new_event_seating_category_association.price.rnd

      # OLD
      old_detail[:sadhak_profile_id] = old_event_order_line_item.sadhak_profile_id
      old_detail[:full_name] = old_event_order_line_item.sadhak_profile.full_name
      old_detail[:syid] = old_event_order_line_item.sadhak_profile.syid
      old_detail[:event_order_line_item_id] = old_event_order_line_item.id
      old_detail[:seating_category] = old_event_order_line_item.category_name
      old_detail[:price] = "#{event.currency_code} #{old_event_order_line_item.category_price.rnd}"
      old_detail[:discount] = "#{event.currency_code} #{old_event_order_line_item.discount.rnd}"
      old_detail[:event_seating_category_association_id] = old_event_order_line_item.event_seating_category_association_id

      result[:total_old_price] += old_event_order_line_item.category_price.rnd
      result[:total_old_discount] += old_event_order_line_item.discount.rnd

      unless new_event_seating_category_association == old_event_order_line_item.event_seating_category_association
        old_detail[:touched_columns] << 'event_seating_category_association_id'
        new_detail[:touched_columns] << 'event_seating_category_association_id'
      end

      seating_categories_released.key?(old_event_order_line_item.event_seating_category_association_id) ? seating_categories_released[old_event_order_line_item.event_seating_category_association_id] += 1 : seating_categories_released[old_event_order_line_item.event_seating_category_association_id] = 1

      unless new_sadhak_profile == old_event_order_line_item.sadhak_profile
        old_detail[:touched_columns] << 'sadhak_profile_id'
        new_detail[:touched_columns] << 'sadhak_profile_id'
      end

      raise SyException, "Name: #{new_sadhak_profile.first_name} and SYID: #{new_sadhak_profile.syid}, Sadhak Profile already registered for Event: #{new_event.event_name}." if (new_detail[:touched_columns].include?("sadhak_profile_id") || result[:is_transfer]) && new_sadhak_profile.events.include?(new_event)

      result[:old_details] << old_detail
      result[:new_details] << new_detail

      result[:touched_event_order_line_items] << old_event_order_line_item.id unless old_detail[:touched_columns].size.zero?

    end

    seating_categories_requested.each do |scr|

      event_seating_category_association_model = new_event_seating_category_associations.find{ |sca| sca.id == scr.id }

      #check if EventSeatingCategoryAssociation belongs to the requested event
      raise SyException, "Seating category (#{event_seating_category_association_model.category_name}) does not belong to requested event." unless event_seating_category_association_model.event == new_event

      #check if number of seats requested are available in this category
      seats_occupied = new_event.valid_event_registrations.where(event_seating_category_association_id:  scr[:id]).count

      total_seats = event_seating_category_association_model.seating_capacity

      seats_available = total_seats - seats_occupied + seating_categories_released[scr.id].to_i

      current_user = Global.instance.try(:current_user)

      unless current_user.present? and (current_user.super_admin? or current_user.event_admin?)
        if seats_available < scr[:seats_requested]
          if seats_available <= 0
            raise SyException, "No seats available in #{event_seating_category_association_model.seating_category.try(:category_name)} category."
          else
            raise SyException, "Only #{seats_available} seats are available in #{event_seating_category_association_model.seating_category.try(:category_name)} category"
          end
        end
      end
    end

    net_amount = ((result[:total_new_price] - result[:total_new_discount]) - (result[:total_old_price] - result[:total_old_discount])).rnd

    result[:net_result] = net_amount

    result[:pay] = true if net_amount.positive?

    result[:refund] = true if net_amount.negative? || net_amount.zero?

    result

  end

  def generate_registration_receipt

    raise "No Event found for this Event Order." unless event

    gateway = TransferredEventOrder.gateways.find {|g| g[:payment_method] == payment_method }

    data = {
        event: event,
        currency: event.currency_code,
        gateway: gateway,
        payment: gateway.present? ? gateway[:model].try(:constantize).try(:where, { gateway[:transaction_id] => transaction_id, status: gateway[:success] }).try(:last) : nil,
        event_order: self,
        event_order_line_items: event_order_line_items.includes(:event_registration, :sadhak_profile, :event_seating_category_association)
    }

    self.generate_pdf(:pdf, data, 'event_orders/registration_receipt.html.erb')

  end

  def is_registration_changes_possible(current_user)
    !event.is_in_india? || (event.is_in_india? && (current_user.try(:super_admin?) || current_user.try(:india_admin?)))
  end

  def is_only_upgrade_possible?(current_user)
    event.is_in_india? && !(current_user.try(:super_admin?) || current_user.try(:india_admin?))
  end

  private

  # Email sender if application submitted against pre approval event
  def send_pre_approval_email
    begin
      event = self.event
      if self.status == 'approve'
        status_string = 'Approved'
      elsif self.status == 'rejected'
        status_string = 'Not Approved'
      else
        status_string = ''
      end
      subject = "Application ##{self.reg_ref_number} #{status_string} for event - #{event.event_name_with_location}."
      sadhak_emails = self.event_order_line_items.collect{|item| item.try(:sadhak_profile).try(:email)}
      begin
        from = GetSenderEmail.call(event)
        ApplicationMailer.send_email(from: from, recipients: self.guest_email, cc: sadhak_emails, subject: subject, template: 'pre_approval_email', event_order: self, event: event).deliver
      rescue => e
        logger.info("EventOrder: send_pre_approval_email, Error occured while sending: #{e.message}")
        Rollbar.error(e)
      end
    rescue => e
      logger.info("Error in sending pre-approval application confirmation or rejection email: error: #{e.message}")
      Rollbar.error(e)
    end
  end

  # To validate forum, Event and profile details before registration in case of forums
  def self.validate_forum_details(params)
    begin

      #Get forum details
      sy_club = SyClub.where(id: params[:sy_club_id]).includes(:approved_members, { address: [:db_city, :db_state, :db_country] }).last
      raise SyException, "Forum not found with id: #{params[:sy_club_id]}" unless sy_club.present?

      data = sy_club.check_transfer(params)

      # To ensure that all sadhak belongs to India only or outside only.
      sadhak_profiles = SadhakProfile.where(id: params[:sadhak_profiles].collect{|s| s.syid}).includes({ address: [:db_city, :db_state, :db_country]})
      raise SyException, 'Sadhak Profiles not found.' unless sadhak_profiles.present?

      # Verify that sadhak profiles already registered for this forum.
      data[:data].each do |info|

        profile = sadhak_profiles.find{|sp| sp.syid == info[:syid]}
        raise SyException, "Sadhak Profile not found with SYID: #{info[:syid]}" unless profile.present?

        raise SyException, "#{profile.syid} is already registered to #{sy_club.name}" if (sy_club.approved_members.include?(profile) and not params[:is_renewal_process])

        if params[:is_renewal_process]
          raise SyException, "#{profile.syid} is not eligible for renew on #{sy_club.name}" unless info[:can_renew]
        end

      end

      raise SyException, 'Some profile(s) are eligible for transfer/renew and some are new registration(s). cannot process together. Aborting.' if (not data[:fresh_registration] and not data[:can_transfer] and not data[:can_renew])

      if data[:can_transfer]
        sy_club.do_transfer(data.merge(guest_email: params[:guest_email]))
      end

    rescue SyException => e
      result = e.message
    rescue Exception => e
      result = e.message
    end

    result
  end

  # Create registrations on approval of application in case of pre approval event.
  def create_pre_approval_event_free_registrations

    logger.info("EventOrder:create_pre_approval_event_free_registrations: Start - Event Order Id: #{self.id}")

    sadhak_emails = []
    syids = []

    # Create event registrations
    self.event_order_line_items.each do |item|

      sadhak_profile = item.try(:sadhak_profile)

      errors.add("#{sadhak_profile.try(:syid)}", "-#{sadhak_profile.try(:full_name)} is already registered.") if (item.event_registration.present? or sadhak_profile.events.include?(self.event))

      sadhak_emails.push(sadhak_profile.try(:email))

      syids.push(sadhak_profile.try(:syid))

    end

    logger.info(errors.full_messages) unless errors.empty?

    if errors.empty? && self.update(status: EventOrder.statuses['success'], transaction_id: "FREE-#{SecureRandom.base64(8).to_s}", payment_method: 'FREE')

      # Send email
      begin
        from = GetSenderEmail.call(self.event)
        ApplicationMailer.send_email(from: from, recipients: self.guest_email, cc: sadhak_emails, subject: "Registration(s) successful ##{self.reg_ref_number} ##{syids.join(',')} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", template: 'free_order_confirmation', event_order: self).deliver if self.success?

        # Disable for now : As per request on email Fwd: to remove entry cards details
        # self.delay.send_entry_cards(from: from)

      rescue => e
        Rollbar.error(e)
        logger.info("EventOrder:create_pre_approval_event_free_registrations: Event Order Id: #{self.id} - Free email sending error: #{e.message}")
      end

    end

    logger.info("EventOrder:create_pre_approval_event_free_registrations: End - Event Order Id: #{self.id}")

    errors.empty?
  end

  def self.preloaded_data
    EventOrder.includes(
      {sadhak_profiles: [{ address: [:db_city, :db_state, :db_country]}, :events]}, :event_order_line_items, :user, {event: [:event_seating_category_associations, :seating_categories, { address: [:db_city, :db_state, :db_country] }, {discount_plan: [:events]}]}, :registration_center)
  end
end
