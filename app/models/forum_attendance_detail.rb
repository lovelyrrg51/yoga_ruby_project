class ForumAttendanceDetail < ApplicationRecord
  acts_as_paranoid

  has_paper_trail class_name: 'ForumAttendanceDetailVersion', only: [:digital_asset_id, :sy_club_id, :conducted_on, :creator_id, :deleted_at, :edit_count, :last_updated_by_id, :venue], skip: [], on: [:update, :destroy]
  attr_accessor :conducted_on_in_time
  # Associations
  belongs_to :digital_asset
  belongs_to :sy_club
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :who_last_updated, class_name: 'User', foreign_key: 'last_updated_by_id'
  has_many :forum_attendances
  has_one :who_last_updated_sadhak_profile, through: :who_last_updated, source: :sadhak_profile
  has_many :current_forum_attendances, lambda { where(forum_attendances: {is_current_forum_member: [true, nil ]}).order('forum_attendances.id DESC') }, class_name: 'ForumAttendance'
  has_many :other_forum_attendances, lambda { where(forum_attendances: {is_current_forum_member: false }).order('forum_attendances.id DESC') }, class_name: 'ForumAttendance'

  scope :sy_club_id, lambda { |sy_club_id| where(sy_club_id: sy_club_id) }
  scope :digital_asset_id, lambda { |digital_asset_id| where(digital_asset_id: digital_asset_id) }
  scope :conducted_on, lambda { |conducted_on| where(conducted_on: conducted_on) }

  validates :conducted_on, presence: true
  validates :edit_count, numericality: { only_integer: true, less_than_or_equal_to: FORUM_ATTENDANCE_ALLOWED_EDIT_COUNT, greater_than_or_equal_to: 0 }
  validate :validate_conducted_on, if: :conducted_on_changed?

  before_create :is_creating_first_attendance?
  before_create :assign_creator
  before_save :assign_last_updated_by, :is_editable?
  before_validation :update_conducted_on_time

  delegate :asset_name, to: :digital_asset, allow_nil: true
  delegate :published_on, to: :digital_asset, allow_nil: true
  delegate :name, to: :sy_club, allow_nil: true, prefix: 'forum'
  delegate :syid, to: :who_last_updated_sadhak_profile, prefix: 'who_last_updated', allow_nil: true
  delegate :full_name, to: :who_last_updated_sadhak_profile, prefix: 'who_last_updated', allow_nil: true
  accepts_nested_attributes_for :current_forum_attendances, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :other_forum_attendances, reject_if: :all_blank, allow_destroy: true

  def attendance_percentage
    '%.2f' %(forum_attendances.select(&:is_attended).size * 100.00 / forum_attendances.size)
  end

  def conducted_on_in_time
    return @conducted_on_in_time if @conducted_on_in_time
    return conducted_on.try(:strftime, "%I:%M %p") if conducted_on.present?
    "12:00 PM"
  end

  private

  def assign_creator
    self.creator = $current_user
    throw(:abort) unless errors.empty?
  end

  def assign_last_updated_by
    self.who_last_updated = $current_user
    throw(:abort) unless errors.empty?
  end

  def validate_conducted_on
    return if digital_asset.blank?
    errors.add(:date, 'is already selected.') if self.class.where(digital_asset_id: digital_asset_id, sy_club_id: sy_club_id, conducted_on: conducted_on).exists?
    errors.add(:selected, "date should be in #{self.digital_asset.published_on} to #{self.digital_asset.expires_at}") unless (self.digital_asset.published_on..self.digital_asset.expires_at).include?(self.conducted_on.to_date)
    throw(:abort) unless errors.empty?
  end

  def is_creating_first_attendance?
    errors.add(:attendance, 'is already created for this episode.') if self.class.where(digital_asset_id: digital_asset_id, sy_club_id: sy_club_id).exists?
    throw(:abort) unless errors.empty?
  end

  def is_editable?
    errors.add(:attendance, 'modification is not allowed. If you have any query, Please contact ashram.') if created_at.present? && (Time.zone.now.to_date - created_at.to_date).to_i >= FORUM_ATTENDANCE_EDITABLE_VALIDITY unless $current_user.super_admin? || $current_user.club_admin? || $current_user.india_admin?
    throw(:abort) unless errors.empty?
  end

  def update_conducted_on_time
    return if conducted_on.blank?
    time = Time.parse(conducted_on_in_time)
    self.conducted_on = conducted_on.change({hour: time.hour, min: time.min})
  end

  public

  def notify_board_members_about_attendance_edit
    begin
      header = %w(FORUM_NAME FORUM_ID EPISODE_NAME DATE_OF_EPISODE SYID FULL_NAME ATTENDANCE_STATUS ATTENDANCE_MARKED_DATE LAST_ATTENDANCE_MARKED_BY)

      rows = []

      forum_attendances.order('is_current_forum_member DESC').each do |forum_attendance|
        sadhak_profile = forum_attendance.sadhak_profile

        row = []
        row << forum_name
        row << sy_club_id
        row << asset_name
        row << conducted_on.try(:strftime, "%d-%m-%Y %I:%M:%S %p")
        row << sadhak_profile.try(:syid)
        row << sadhak_profile.try(:full_name)
        row << (forum_attendance.is_attended ? 'Present' : 'Absent')
        row << forum_attendance.updated_at.strftime('%Y-%m-%d')
        row << "#{forum_attendance.who_last_updated_syid}-#{forum_attendance.who_last_updated_full_name}"

        rows << row
      end

      from = GetSenderEmail.call(sy_club)

      h2_message = "Episode: #{digital_asset.try(:asset_name)} - Conducted On: #{conducted_on.strftime('%d-%m-%Y')} - #{sy_club.name} Attendance."

      sy_club.sadhak_profiles.each do |board_member|
        next unless board_member.email.to_s.is_valid_email?
        ApplicationMailer.send_email(
          from: from,
          recipients: board_member.email,
          subject: "Episode: #{digital_asset.asset_name} conducted on #{conducted_on.strftime('%d-%m-%Y')} on #{sy_club.name} attendance.",
          forum_attendance_detail: self,
          h2_message: h2_message,
          attachments: Hash["#{sy_club_id}_#{asset_name}_Attendance_Report.xls", GenerateExcel.generate(header: header, rows: rows)],
          template: 'send_episode_attendance_if_edited',
          board_member: board_member).deliver
      end
    rescue => e
      errors.add(:error, e.message)
      Rollbar.error(e)
    end

    throw(:abort) unless errors.empty?

  end
end
