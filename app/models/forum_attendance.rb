class ForumAttendance < ApplicationRecord
  acts_as_paranoid

  has_paper_trail class_name: 'ForumAttendanceVersion', only: [:sadhak_profile_id, :sy_club_member_id, :forum_attendance_detail_id, :is_attended, :deleted_at, :last_updated_by, :is_current_forum_member], skip: [], on: [:update, :destroy]

  belongs_to :sadhak_profile
  belongs_to :sy_club_member
  belongs_to :forum_attendance_detail, touch: true
  belongs_to :who_last_updated, class_name: 'User', foreign_key: 'last_updated_by'
  has_one :digital_asset, through: :forum_attendance_detail
  has_one :sy_club, through: :forum_attendance_detail
  has_one :who_last_updated_sadhak_profile, through: :who_last_updated, source: :sadhak_profile

  scope :sadhak_profile_id, lambda { |sadhak_profile_id| where(sadhak_profile_id: sadhak_profile_id) }
  scope :sy_club_member_id, lambda { |sy_club_member_id| where(sy_club_member_id: sy_club_member_id) }
  scope :forum_attendance_detail_id, lambda { |forum_attendance_detail_id| where(forum_attendance_detail_id: forum_attendance_detail_id) }
  scope :is_attended, lambda { |is_attended| where(is_attended: is_attended) }
  scope :is_current_forum_member, lambda { |is_current_forum_member| where(is_current_forum_member: is_current_forum_member) }
  scope :syid, lambda { |syid| where(forum_attendances: {sadhak_profile_id: syid[/-?\d+/].to_i}) }
  scope :first_name, lambda { |first_name| joins(:sadhak_profile).where('sadhak_profiles.first_name ILIKE ?', "%#{first_name.to_s.strip}%" ) }

  validates :sadhak_profile_id, :forum_attendance_detail_id, presence: true
  validates :sadhak_profile_id, uniqueness: { scope: :forum_attendance_detail_id, message: 'has been already added to attendance list.' }, on: :create

  # Callbacks
  before_create :assign_sy_club_member
  after_commit :assign_is_current_forum_member, if: proc{ |at| at.sy_club_member_id? }
  before_save :assign_last_updated_by, :is_editable?
  before_save :check_for_already_marked_present?, if: Proc.new{|fa| is_attended_changed? && fa.is_attended? }
  after_save :update_forum_attendance_detail, on: :update

  delegate :asset_name, to: :digital_asset, allow_nil: true
  delegate :name, to: :sy_club, prefix: 'forum', allow_nil: true
  delegate :syid, to: :who_last_updated_sadhak_profile, prefix: 'who_last_updated', allow_nil: true
  delegate :full_name, to: :who_last_updated_sadhak_profile, prefix: 'who_last_updated', allow_nil: true

  private

  def assign_sy_club_member
    errors.add("SY#{self.sadhak_profile_id}", 'is registered on more than one forum.') if self.sadhak_profile.present? && self.sadhak_profile.active_club_ids.size > 1
    errors.add("SY#{self.sadhak_profile_id}", 'is not registered on any forum.') unless self.sadhak_profile&.active_club_ids.present?
    self.sy_club_member = self.sadhak_profile&.forum_memberships&.first
    errors.empty?
  end

  def assign_last_updated_by
    self.who_last_updated = $current_user
    errors.empty?
  end

  def assign_is_current_forum_member
    self.is_current_forum_member = forum_attendance_detail.sy_club_id == sy_club_member.sy_club_id
    errors.empty?
  end

  def check_for_already_marked_present?
    forum_attendance = ForumAttendance.joins(:forum_attendance_detail).where(forum_attendance_details: {digital_asset_id: self.forum_attendance_detail.digital_asset_id}, forum_attendances: {sadhak_profile_id: self.sadhak_profile_id, is_attended: true}).first
    errors.add(:sy, "#{self.sadhak_profile.id}-#{self.sadhak_profile.full_name} is already attended episode #{self.asset_name} on #{forum_attendance.forum_attendance_detail.conducted_on.to_date} to #{forum_attendance.forum_name}.") if forum_attendance.present?
    errors.empty?
  end

  def is_editable?
    errors.add(:attendance, 'modification is not allowed. If you have any query, Please contact ashram.') if self.forum_attendance_detail&.created_at.present? && (Time.zone.now.to_date - self.forum_attendance_detail.created_at.to_date).to_i >= FORUM_ATTENDANCE_EDITABLE_VALIDITY unless $current_user&.super_admin? || $current_user&.club_admin? || $current_user&.india_admin?
    errors.empty?
  end

  def update_forum_attendance_detail
    self.forum_attendance_detail.touch
  end

  public

  def notify_by_email
    ApplicationMailer.send_email(from: GetSenderEmail.call(forum_attendance_detail.sy_club), recipients: sadhak_profile.email, template: 'forum_attendance_notification_to_sadhak', subject: "Forum Attendance - #{asset_name}.", forum_attendance: self).deliver if sadhak_profile.email.is_valid_email?
  end

  def notify_by_sms
    sadhak_profile.send_sms_to_sadhak("Namah Shivay Ji\n#{sadhak_profile.syid}, #{sadhak_profile.full_name}, #{sadhak_profile.active_forum_name}\nYour Attendance has been marked #{is_attended ? 'Present' : 'Absent'} for #{forum_attendance_detail.asset_name} by #{who_last_updated_syid}-#{who_last_updated_full_name} which was conducted on #{forum_attendance_detail.conducted_on.try(:strftime, "%d-%m-%Y %I:%M:%S %p")} in the #{forum_name}.\n(In case of any discrepancy please write to clp@shivyogindia.com)\nThank You.") if sadhak_profile.mobile.present? && ENV['ENVIRONMENT'] == 'production'
  end

  class << self

    def notify_attendance_updates(forum_attendance = {})
      return if forum_attendance.blank?
      forum_attendance_model = new(forum_attendance)
      forum_attendance_model.notify_by_email
      forum_attendance_model.notify_by_sms
    end

  end
end
