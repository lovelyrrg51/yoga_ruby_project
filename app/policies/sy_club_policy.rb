# frozen_string_literal: true

class SyClubPolicy < ApplicationPolicy
  attr_reader :user, :sy_club, :permissions
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |_, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, sy_club)
    @user = user
    @sy_club = sy_club
    @permissions = user.try(:permissions, record) || {}
  end

  def index?
    user&.super_admin? || user&.club_admin? || permissions[:country_admin] ||
      user&.is_country_admin?
  end

  def create?
    index?
  end

  def new?
    index?
  end

  def show?
    index?
  end

  def update?
    user&.super_admin? || user&.club_admin? || permissions[:country_admin] ||
      user == sy_club.user
  end

  def destroy?
    user&.super_admin? || user&.club_admin?
  end

  def admin_transfer?
    user&.super_admin? || user&.club_admin? ||
      (user&.india_admin? && sy_club.try(:address).try(:country_id) == 113)
  end

  def members?
    show? || sy_club.is_board_member?(user&.sadhak_profile&.id)
  end

  def forum_admin?
    user&.super_admin?
  end

  def offline_forum_data_migration?
    user&.super_admin?
  end

  def sadhak_non_members?
    user.present? and (user.super_admin? or user.club_admin? or permissions[:country_admin] or user.is_country_admin?)
  end

  def expired_forum_members?
    user.present? and user.super_admin?
  end

end
