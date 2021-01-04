class SyClubMemberActionDetail < ApplicationRecord
  include AASM

  default_scope { where(is_deleted: false) }

  scope :sadhak_profile_id, ->(sadhak_profile_id) do
    where(sadhak_profile_id: sadhak_profile_id)
  end
  scope :from_club_id, ->(from_club_id) do
    joins(:from_sy_club_member).where(sy_club_id: from_club_id)
  end
  scope :to_club_id, ->(to_club_id) do
    joins(:to_sy_club_member).where(sy_club_id: to_club_id)
  end
  scope :status, ->(status) { where(status: status) }
  scope :requester_id, ->(requester_id) { where(requester_id: requester_id) }
  scope :responder_id, ->(responder_id) { where(responder_id: responder_id) }

  validates :from_sy_club_member_id, :to_sy_club_member_id,
    :from_event_registration_id, :to_event_registration_id,
    :sadhak_profile_id, presence: true

  belongs_to :sadhak_profile
  belongs_to :requester_user, class_name: 'User', foreign_key: 'requester_id', optional: true
  belongs_to :responder_user, class_name: 'User', foreign_key: 'responder_id', optional: true
  belongs_to :from_sy_club_member, -> { where is_deleted: [true, false] },
    class_name: 'SyClubMember', foreign_key: 'from_sy_club_member_id'
  belongs_to :to_sy_club_member, -> { where is_deleted: [true, false] },
    class_name: 'SyClubMember', foreign_key: 'to_sy_club_member_id'
  belongs_to :from_event_registration, class_name: 'EventRegistration',
    foreign_key: 'from_event_registration_id'
  belongs_to :to_event_registration, class_name: 'EventRegistration',
    foreign_key: 'to_event_registration_id'
  has_one :from_club, -> { where is_deleted: [true, false] }, through: :from_sy_club_member, source: :sy_club
  has_one :to_club, -> { where is_deleted: [true, false] }, through: :to_sy_club_member, source: :sy_club

  before_create :is_transfer_in_out_club_enabled?, :assign_requester_user_and_ip
  before_save :is_transfer_in_out_club_enabled?, :assign_action_time_and_responder_user, if: Proc.new{|inst| inst.approved? }

  enum action_type: [ :transfer, :renew ]

  enum status: [ :requested, :approved ]

  aasm column: :status, enum: true, whiny_transitions: false do
    state :requested, initial: true
    state :approved

    event :approve, before: [:has_valid_state?, :assign_action_time_and_responder_user], guards: [:is_transfer_in_out_club_enabled?] do
      transitions from: :requested, to: :approved
    end
  end

  def self.preloaded_data
    SyClubMemberActionDetail.order(:id).includes(:sadhak_profile, :requester_user, :responder_user, { from_club: [ sy_club_sadhak_profile_associations: [:sadhak_profile] ] }, { to_club: [ sy_club_sadhak_profile_associations: [:sadhak_profile] ] })
  end

  private

  def assign_action_time_and_responder_user
    self.action_time ||= Time.now
    self.responder_user = $current_user
  end

  def is_transfer_in_out_club_enabled?
    errors.add(:requested, "forum '#{self.to_club&.name}' is in disable state. Please contact to board members.") unless self.to_club&.enabled?
    errors.empty?
  end

  # Check that request for transfer profile is in from_club board members list.
  def is_request_for_transfer_profile_board_member?
    errors.add(:profile, "Name: #{self.sadhak_profile.full_name.titleize} SYID: #{self.sadhak_profile_id} is board member of #{self.from_club.name.titleize} forum.") if self.from_club.is_board_member?(self.sadhak_profile_id)
    errors.empty?
  end

  def has_valid_state?
    errors.add(:invalid, 'aasm transition.') unless self.requested?
    errors.empty?
  end

  def assign_requester_user_and_ip
    self.requester_user = $current_user
    self.ip = $ip
  end
end
