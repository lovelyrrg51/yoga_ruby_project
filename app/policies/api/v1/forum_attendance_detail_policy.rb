class Api::V1::ForumAttendanceDetailPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :forum_attendance_detail, :is_allowed
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end


  def initialize(user, forum_attendance_detail)
    @user = user
    @forum_attendance_detail = forum_attendance_detail
    sadhak_profile = @user.try(:sadhak_profile)
    sy_club = sadhak_profile.try(:sy_clubs).try(:first)
    languages = sy_club.try(:content_type).to_s.split(',').map(&:downcase)
    @is_allowed = (sy_club.present? && (sadhak_profile.try(:active_club_ids) || []).size > 0 && sy_club.has_board_members_paid && sy_club.active_members_count >= sy_club.min_members_count && @forum_attendance_detail.present? && languages.include?(@forum_attendance_detail.digital_asset.language.to_s.downcase))
  end

  def index?
    user.present? && (user.super_admin? || user.club_admin? || user.india_admin? || is_allowed)
  end

  def create?
    index?
  end

  def show?
    index?
  end

  def update_edit_count?
    index?
  end

  def update?
    user.present? && (user.super_admin? || user.club_admin? || user.india_admin?)
  end

  def destroy?
    user.present? && (user.super_admin? || user.india_admin?)
  end

  def mark?
    index?
  end

  def update_attendance?
    index?
  end

  def edit_details?
    index?
  end

end
