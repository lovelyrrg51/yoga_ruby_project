class EventOrderLineItem < ApplicationRecord
  include AASM
  acts_as_paranoid

  def paranoia_restore_attributes
    {
      deleted_at: nil,
      is_deleted: false
    }
  end

  def paranoia_destroy_attributes
    {
      deleted_at: current_time_from_proper_timezone,
      is_deleted: true
    }
  end

  # Papertrail logging
  has_paper_trail class_name: 'EventOrderLineItemVersion', only: [:event_order_id, :sadhak_profile_id, :seating_category_id, :price, :event_seating_category_association_id, :status, :transferred_ref_number, :is_deleted, :discount, :total_tax_detail], skip: [:tax_details, :tax_types], on: [:update, :destroy]

  diff :event_order_id, :sadhak_profile_id, :seating_category_id, :price, :event_seating_category_association_id, :status, :transferred_ref_number, :is_deleted, :discount, :total_tax_detail, :updated_at

  scope :event_order_id, ->(event_order_id) { where event_order_id: event_order_id }

  belongs_to :event_order
  belongs_to :sadhak_profile
  belongs_to :seating_category, optional: true
  belongs_to :event_seating_category_association
  has_one :event_registration
  belongs_to :event_type_pricing, optional: true
  has_one :special_event_sadhak_profile_other_info, dependent: :destroy

  has_one :event, through: :event_order, source: :event
  has_one :payment_refund_line_item, lambda { where(payment_refund_line_items: {status: PaymentRefundLineItem.statuses["requested"]}) }
  has_many :payment_refund_line_items, dependent: :destroy
  has_one :sy_club_member, through: :event_registration

  belongs_to :transferred_event_order, class_name: 'EventOrder', foreign_key: 'transferred_ref_number', primary_key: "reg_ref_number", optional: true

  delegate :price, to: :event_seating_category_association, prefix: "category", allow_nil: true
  delegate :category_name, to: :event_seating_category_association, allow_nil: true
  delegate :reg_ref_number, to: :event_order, allow_nil: true
  delegate :full_name, to: :sadhak_profile, allow_nil: true
  delegate :syid, to: :sadhak_profile, allow_nil: true

  after_create :assign_registration_number, :assign_taxes
  after_create :assign_line_item_id_to_special_event_sadhak_profile_other_info, if: Proc.new{|item| item.event.is_ashram_residential_shivir? }
  before_create :create_total_tax_detail
  after_save :update_event_order_total_discount_and_total_discount, if: :is_discount_or_status_or_seating_category_or_transferred_ref_no_changed?
  before_save :check_for_rejected_application ,if: :is_deleted_changed?
  after_destroy :update_event_order_total_discount_and_total_discount

  serialize :tax_types, Array
  serialize :tax_details, JSON
  serialize :total_tax_detail, JSON

  enum status: {
    cancelled: 0,
    transferred: 1,
    updated: 2,
    success: 3,
    cancelled_refunded: 4,
    cancelled_refund_pending: 5,
    upgraded: 6, downgraded: 7,
    name_changed: 8,
    shivir_changed: 9,
    downgrade_requested: 10,
    shivir_change_requested: 11,
    name_change_requested: 12,
    upgrade_requested: 13,
    expired: 14,
    renewed: 15
  }
  # Cancelled-Refunded, cancelled-Refund Pending, Upgrade, Downgrade and Name change, Shivir change status can be captured in a new column Event Registration Status . for eg. If some sadhak has done upgrade then Event Registration Status can be “Upgrade”

  aasm column: :status, enum: true do
    state :success, initial: true
    state :cancelled
    state :transferred
    state :updated
    state :cancelled_refunded
    state :cancelled_refund_pending
    state :upgraded
    state :downgraded
    state :name_changed
    state :shivir_changed
    state :downgrade_requested
    state :shivir_change_requested
    state :name_change_requested
    state :upgrade_requested
    state :expired
    state :renewed
  end

  def is_discount_or_status_or_seating_category_or_transferred_ref_no_changed?
    update_needed = (saved_change_to_discount? or saved_change_to_transferred_ref_number? or saved_change_to_status? or saved_change_to_event_seating_category_association_id?)
    Rails.logger.info "Will call model callback update_event_order_total_discount_and_total_discount? #{update_needed}"
    update_needed
  end

  # Model callback definations
  def assign_registration_number
    # self.registration_number = self.id
    # self.save
    self.update_column("registration_number", self.id)
  end

  def self.preloaded_data
    return EventOrderLineItem.includes(:sadhak_profile, :event_seating_category_association, :event_order, :payment_refund_line_item, :event_registration)
  end

  # To save tax_types details, in case of future need
  def assign_taxes
    if self.event.tax_types.present?
      taxes = []
      self.event.event_tax_type_associations.each do |association|
        tax = association.as_json
        tax[:tax_type_name] = association.tax_type_name
        taxes.push(tax)
      end
      update_columns(tax_types: taxes.as_json)
    end
    errors.empty?
  end

  def self.valid_line_item_statuses
    return (EventOrderLineItem.statuses.slice('success', 'updated', 'cancelled_refund_pending', 'upgraded', 'downgraded', 'name_changed', 'downgrade_requested', 'shivir_change_requested', 'name_change_requested', 'upgrade_requested').values + [nil])
  end

  def update_item_tax_detail(tax_details = {})
    logger.info("Model: EventOrderLineItem, Method: update_item_tax_detail : item id: #{self.try(:id)} - Start")

    logger.info("Model: EventOrderLineItem, Method: update_item_tax_detail : tax_details is not present.") and return unless tax_details.present?

    begin
      tax_details[:created_at] = DateTime.now.to_s
      _tax_details = self.tax_details || []
      _tax_details.push(tax_details.as_json)

      # Update tax_detail
      total_tax_detail = (self.total_tax_detail || {total_tax_paid: 0, tax_breakup: [], total_convenience_charges: 0, tax_breakup_on_convenience_charges: []}).deep_symbolize_keys
      total_tax_detail[:total_tax_paid] = (total_tax_detail[:total_tax_paid] + tax_details[:total_tax_applied]).rnd
      total_tax_detail[:total_convenience_charges] = (total_tax_detail[:total_convenience_charges] + tax_details[:convenience_charges]).rnd

      tax_details[:tax_breakup] ||= []

      # Update or push tax breakup
      tax_details[:tax_breakup].each do |breakup|
        # Find existing tax break up
        found = (total_tax_detail[:tax_breakup] || []).find{ |t| t[:tax_name].present? and t[:tax_name].downcase == breakup[:tax_name].downcase }

        # If found
        if found.present?
          found[:amount] += breakup[:amount].rnd
        else
          total_tax_detail[:tax_breakup].push(breakup)
        end
      end

      # Update or push tax breakup for convenience charges
      (tax_details[:tax_breakup_on_convenience_charges] || []).each do |breakup|

        # Find existing convenience charge tax break up
        found = (total_tax_detail[:tax_breakup_on_convenience_charges] || []).find{ |t| t[:tax_name].present? and t[:tax_name].downcase == breakup[:tax_name].downcase }

        # If found
        if found.present?
          found[:amount] += breakup[:amount].rnd
        else
          total_tax_detail[:tax_breakup_on_convenience_charges].push(breakup)
        end
      end

      # Update event order with updated tax details
      Rails.logger.info("EventOrderLineItem: update_item_tax_detail: Some error ocuured while updating tax details in event order line item: #{self.id}") unless self.update_columns(total_tax_detail: total_tax_detail, tax_details: _tax_details)

    rescue => e
      logger.info("Model: EventOrderLineItem, Method: update_item_tax_detail : error occured: #{e.message}")
      Rollbar.error(e)
    end
    logger.info("Model: EventOrderLineItem, Method: update_item_tax_detail : item id: #{self.try(:id)} - End")
  end

  # Upgrade case
  def determine_final_status(reg_detail)
    return unless reg_detail.present?
    is_transfer = reg_detail[:is_transferred]
    touched_columns = reg_detail[:touched_columns]
    category_amount_diff = reg_detail[:item_payable_amount].to_f
    if touched_columns.size > 0
      if is_transfer
        new_status = EventRegistration.statuses["shivir_changed"]

      elsif category_amount_diff > 0
        new_status = EventRegistration.statuses["upgraded"]

      elsif category_amount_diff < 0
        new_status = EventRegistration.statuses["downgraded"]

      elsif touched_columns.include?("sadhak_profile_id")
        new_status = EventRegistration.statuses["name_change_requested"]
      end

    else
      new_status = EventRegistration.statuses["success"]
    end
    return new_status
  end

  # Retrun expiration date of membership
  def expiration_date
    return self.try(:event_registration).try(:expiration_date).to_s
  end

  def seating_categories_for_upgration
    event.event_seating_category_associations.where("event_seating_category_associations.price >= ?", event_seating_category_association.try(:price))
  end

  private

  def update_event_order_total_discount_and_total_discount
    Rails.logger.info "EventOrderLineItem: update_event_order_total_discount_and_total_discount: Updating event order total_amount and total_discount for line item: #{self.try(:id)}"
    total_discount = self.event_order.valid_line_items.pluck(:discount).map { |x| x.to_f }.sum
    total_amount = self.event_order.event_seating_category_associations.pluck(:price).map { |x| x.to_f }.sum
    Rails.logger.info "total_discount: #{total_discount}"
    Rails.logger.info "total_amount: #{total_amount}"
    self.event_order.update_columns(total_discount: total_discount, total_amount: total_amount)
    return errors.empty?
  end

  def create_total_tax_detail
    self.total_tax_detail = {total_tax_paid: 0, tax_breakup: [], total_convenience_charges: 0, tax_breakup_on_convenience_charges: []}
  end

  def check_for_rejected_application
    sadhak_profile = self.sadhak_profile
    errors.add(:sadhak_profile, "#{sadhak_profile.try(:syid)}-#{sadhak_profile.try(:full_name)} application is disapproved by Ashram. Contact ashram for more details.") if self.event_order.event.pre_approval_required? && self.event_order.rejected?
    errors.empty?
  end

  def assign_line_item_id_to_special_event_sadhak_profile_other_info
    special_event_sadhak_profile_other_info = SpecialEventSadhakProfileOtherInfo.where(sadhak_profile_id: sadhak_profile_id, event: event, event_order_line_item_id: nil).order('created_at DESC').first
    errors.add(:sy, "#{sadhak_profile_id} other info not found.") unless special_event_sadhak_profile_other_info.present?
    special_event_sadhak_profile_other_info.update_columns(event_order_line_item_id: id)
    errors.empty?
  end

end
