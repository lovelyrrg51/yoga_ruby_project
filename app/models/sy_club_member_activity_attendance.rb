class SyClubMemberActivityAttendance < ApplicationRecord
  belongs_to :sadhak_profile
  belongs_to :sy_club_member
  belongs_to :event
  belongs_to :sy_club

 	scope :sy_club_id, ->(sy_club_id) { where(sy_club_id: sy_club_id) }
 	scope :event_id, ->(event_id) { where(event_id: event_id) }

  validates :sadhak_profile_id, :sy_club_member_id, :event_id, :sy_club_id, presence: true
  validates :sy_club_member_id, uniqueness: { scope: :event_id }

  before_save :validate_membership

  def self.included_associations
    SyClubMemberActivityAttendance.includes(:sy_club_member, :sy_club, :sadhak_profile, :event)
  end

  private
  # Will validate sadhak membership to current forum
  def validate_membership
    errors.add("#{self.sadhak_profile.syid}", "is not active member to forum #{self.sy_club.name}.") unless self.sy_club_member.approve?
    errors.empty?
  end

end
