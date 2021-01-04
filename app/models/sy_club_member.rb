# frozen_string_literal: true

class SyClubMember < ApplicationRecord
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

  belongs_to :sy_club
  belongs_to :sadhak_profile
  belongs_to :sy_club_validity_window, optional: true
  belongs_to :event_registration, optional: true
  has_one :event_order_line_item, through: :event_registration
  belongs_to :transferred_to_club, class_name: 'SyClub',
    foreign_key: 'transferred_to_club_id', optional: true
  has_many :forum_attendances, dependent: :destroy

  delegate :name, to: :transferred_to_club, prefix: 'transferred_club', allow_nil: true
  delegate :name, to: :sy_club, prefix: 'forum', allow_nil: true
  delegate :full_name, to: :sadhak_profile, prefix: 'sadhak', allow_nil: true
  delegate :syid, to: :sadhak_profile, prefix: 'sadhak', allow_nil: true
  delegate :clp_event, to: :sy_club, allow_nil: true
  delegate :board_member_position, to: :sadhak_profile, allow_nil: true
  delegate :board_member_forum_name, to: :sadhak_profile, allow_nil: true

  validates :sadhak_profile_id, uniqueness: {
    scope: :sy_club_id,
    conditions: ->{
      where(is_deleted: false, status: SyClubMember.statuses["approve"])
    },
    message: 'member already registered for this forum.'
  }

  scope :sy_club_id, ->(sy_club_id) { where sy_club_id: sy_club_id }
  scope :status, ->(status) { where(status: SyClubMember.statuses[status]) }
  scope :sadhak_syid, ->(syid) do
    joins(:sadhak_profile)
      .where('sadhak_profiles.syid ILIKE ?', "%#{syid.to_s.strip}%")
  end
  scope :sadhak_name, ->(name) do
    joins(:sadhak_profile)
      .where("sadhak_profiles.first_name ILIKE :full_name OR sadhak_profiles.last_name ILIKE :full_name OR (sadhak_profiles.first_name || '' || sadhak_profiles.last_name) ILIKE :full_name", full_name: "%#{name.to_s.gsub(/\s+/, "")}%")
  end

  enum virtual_role: {
    organiser: 0
  }
  enum status: {
    pending: 0,
    approve: 1,
    expired: 2,
    renewed: 3,
    transferred: 4,
    cancelled: 5
  }

  after_destroy :update_forum_registration
  after_restore Proc.new{ update_forum_registration(true) }

  include AASM
  aasm column: :status, enum: true do
    state :pending, initial: true
    state :approve
    state :expired
    state :renewed
    state :transferred
    state :cancelled

    event :approve do
      transitions from: [:pending], to: :approve
    end

    event :expired do
      transitions from: [:approve], to: :expired
    end

    event :renewed do
      transitions from: [:expired], to: :renewed
    end

    event :transfer do
      transitions from: [:approve], to: :transferred
    end

    event :cancel do
      transitions from: [:approve], to: :cancelled
    end
  end

  #Method that will remove prevoiusly requested pending requests
  def remove_pendings(reason)
    SyClubMember.pending.where(
      sy_club_id: sy_club_id,
      sadhak_profile_id: sadhak_profile_id
    ).each do |sy_club_member|
      sy_club_member.is_deleted = true
      sy_club_member.metadata = reason
      next if sy_club_member.save
      logger.info "Unable to remove pending record #{sy_club_member.id}."
    end
    true
  end

  # Retrun expiration date of membership
  def expiration_date
    self.try(:event_registration).try(:expiration_date).to_s
  end

  def self.includable_data
    return [:sadhak_profile, :sy_club, {event_registration: [:event_order]}]
  end

  # Generate SY CLUB MEMBER excell
  def generate_member_excel(sy_club_member, type, opts = [])

    # Generate header .
    header = %w(SNO SYID FIRST_NAME LAST_NAME EMAIL MOBILE COUNTRY STATE CITY PROFESSION FORUM_NAME FORUM_ID FORUM_MEMBERSHIP_EXPIRATION_DATE)

    opts.each do |opt|
      header.push(opt[:header_name]) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
    end

    # Hold generated rows
    rows = []

    # Iterate over event registrations with status [nil, updated]
    sy_club_member.each_with_index do |sy_club_member, index|
      # Hold single row
      sadhak_address = sadhak_profile.address
      sadhak_profile = sy_club_member.sadhak_profile

      row = []

      # Push data according to header
      row << (index+1)

      row << sadhak_profile.try(:syid)

      row << sadhak_profile.try(:first_name)

      row << sadhak_profile.try(:last_name)

      row << sadhak_profile.try(:email)

      row << sadhak_profile.try(:mobile)

      row << sadhak_address.try(:country_name)

      row << sadhak_address.try(:state_name)

      row << sadhak_address.try(:city_name)

      row << sadhak_address.try(:street_address)

      row << sadhak_profile.try(:professional_detail).try(:profession).try(:name)

      row << sy_club_member.sy_club.name.try(:titleize)

      row << sy_club_member.sy_club.id

      row << sy_club_member.try(:expiration_date)

      opts.each do |opt|
        row.push(opt[:proc].call(sy_club_member)) if opt[:header_name].present? and opt[:proc].kind_of?(Proc)
      end

      rows.push(row)
    end
    return {header: header, rows: rows}
  end

  def update_forum_registration(restore = false)
    errors.add(:can, 'not remove/add member.') unless approve?
    unless restore
      errors.add(:event_registration, "not found for forum membership of #{sadhak_profile.syid}-#{sadhak_profile.full_name}.") unless event_registration.present?
      errors.add(:can, "not remove forum membership of #{sadhak_profile.syid}-#{sadhak_profile.full_name} as registration is not in success.") unless event_registration.try(:success?)
      errors.add(:line_item, "not found for forum membership of #{sadhak_profile.syid}-#{sadhak_profile.full_name}.") unless event_order_line_item.present?
      event_registration.try(:delete)
      event_order_line_item.try(:delete)
    else
      er = EventRegistration.only_deleted.find_by(id: event_registration_id)
      er.try(:restore)
      EventOrderLineItem.only_deleted.find_by(id: er.event_order_line_item_id).try(:restore) if er.present?
    end

    errors.empty?
  end
end
