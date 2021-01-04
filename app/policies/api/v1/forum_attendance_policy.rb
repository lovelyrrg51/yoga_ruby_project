class Api::V1::ForumAttendancePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :forum_attendance, :is_allowed
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      scope.filter(filtering_params)
    end
  end

  def initialize(user, forum_attendance)
    @user = user
    @forum_attendance = forum_attendance
    sadhak_profile = @user.try(:sadhak_profile)
    sy_club = sadhak_profile.try(:sy_clubs).try(:first)
    languages = sy_club.try(:content_type).to_s.split(',').map(&:downcase)
    @is_allowed = (sy_club.present? && (sadhak_profile.try(:active_club_ids) || []).size > 0 && sy_club.has_board_members_paid && sy_club.active_members_count >= sy_club.min_members_count && @forum_attendance.present? && languages.include?(@forum_attendance.digital_asset.language.to_s.downcase) && sy_club == @forum_attendance.sy_club)
  end

  def index?
    user.present? && (user.super_admin? || user.club_admin? || user.india_admin? || is_allowed)
  end

  def create?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end

  def mark?
    index?
  end
end
