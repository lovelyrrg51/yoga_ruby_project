class SyClubSadhakProfileAssociation < ApplicationRecord
  include AASM

  acts_as_paranoid

  belongs_to :sadhak_profile
  belongs_to :sy_club
  belongs_to :sy_club_user_role
  belongs_to :sy_club_validity_window

  before_save :insert_club_joining_date
  before_save :verify_board_member_uniqueness, :register_to_event, if: Proc.new{ sadhak_profile_id_changed? }
  before_create :approve_organiser
  validates :sadhak_profile, :sy_club, :sy_club_user_role, presence: true
  validates_uniqueness_of :sadhak_profile_id, scope: :sy_club_id, message: 'Board member already assigned a role in this forum.'
  validates_uniqueness_of :sy_club_user_role_id, scope: :sy_club_id, message: 'Role already exist in this forum.'

  default_scope { order(:sy_club_user_role_id) }

  delegate :role_name, to: :sy_club_user_role, allow_nil: true

  attr_accessor :syid, :first_name

  enum status: {
    pending: 0,
    approve: 1,
    expired: 2
  }

  aasm column: :status, enum: true do
    state :pending, initial: true
    state :approve

    event :approve do
      transitions from: [:pending], to: :approve
    end
  end

  def generate_member_id
    "clb_member-#{self.id}"
  end

  def insert_club_joining_date
    if self.status == 'approve'
      self.club_joining_date = DateTime.now
    end
  end

  def approve_organiser
    if self.sy_club_user_role_id.present?
      self.status = 'approve'
    end
  end

  def register_to_event
    begin
      # Get event id based on forum address
      sy_club_address = self.sy_club.address
      raise "#{self.sy_club.try(:name)} address not present. Please contact board member(s)" unless sy_club_address.present?

      event_id = if sy_club_address.country_id == 113 then
                   GlobalPreference.get_value_of('india_forum_organisers_event')
                 elsif sy_club_address.country_id != 113 then
                   GlobalPreference.get_value_of('global_forum_organisers_event')
                 else
                   raise "#{self.sy_club.try(:name)} address country not present. Please contact board member(s)"
                 end
      event = Event.where(id: event_id).includes(:event_registrations).last
      raise "Forum organisers event not found with id(#{event_id}) for #{self.sy_club.try(:name)}(#{self.sy_club_id}) ." unless event.present?

      # Current sadhak registration
      registration = event.event_registrations.where(status: EventRegistration.valid_registration_statuses, sadhak_profile_id: self.sadhak_profile_id).last

      if self.sadhak_profile_id_was.present?
        old_registration = event.event_registrations.where(status: EventRegistration.valid_registration_statuses, sadhak_profile_id: self.sadhak_profile_id_was).last

        old_sadhak_still_board_member = self.class.where.not(sy_club_user_role_id: nil, sy_club_id: self.sy_club_id).where(sadhak_profile_id: self.sadhak_profile_id_was).any?

        if old_registration.present?
          unless old_sadhak_still_board_member
            if registration.present?
              old_registration.destroy
            else
              old_registration.update(sadhak_profile_id: self.sadhak_profile_id)
              old_registration.event_order_line_item.update(sadhak_profile_id: self.sadhak_profile_id)
              registration = old_registration
            end
          end
        end
      end

      unless registration.present?
        # Collect seating deatils
        event_seating_category_association = event.event_seating_category_associations.first
        seating_category_id = event_seating_category_association.seating_category_id
        event_seating_category_association_id = event_seating_category_association.id
        price = event_seating_category_association.price

        # Create event order, line item and registrations
        ApplicationRecord.transaction do

          @event_order = EventOrder.new(event_id: event.id, guest_email: self.try(:sadhak_profile).try(:email), is_guest_user: true, payment_method: 'No Payment', status: EventOrder.statuses['success'], transaction_id: "Offline-#{Time.now.strftime('%d%m%Y%H%M%S%N')}")
          raise @event_order.errors.full_messages.first unless @event_order.save

          @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: self.sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price)
          raise @event_order_line_item.errors.full_messages.first unless @event_order_line_item.save

          EventRegistration.without_callbacks(:notify_registration) do
            @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: self.sadhak_profile_id, event_seating_category_association_id: event_seating_category_association_id, event_id: event.id, event_order_line_item_id: @event_order_line_item.id)
            raise @event_registration.errors.full_messages.first unless @event_registration.save
          end
        end
      end

    rescue Exception => e
      errors.add(:error, e.message)
    end
    errors.empty?
  end

  def verify_board_member_uniqueness
    ass = self.class.joins(:sy_club).where(sadhak_profile_id: self.sadhak_profile_id, sy_clubs: {is_deleted: false}).last
    errors.add(:profile, "#{ass.try(:sadhak_profile).try(:syid)}-#{ass.try(:sadhak_profile).try(:full_name)} is already assigned board member (#{ass.try(:sy_club_user_role).try(:role_name)}) in #{ass.try(:sy_club).try(:name)}") if ass.present?
    errors.empty?
  end
end
