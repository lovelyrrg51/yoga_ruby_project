# frozen_string_literal: true

class SyClubVenueDetailPolicy < ApplicationPolicy
  attr_reader :user, :is_club_creator, :permissions
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_club_venue_detail)
    @user = user
    @is_club_creator = (user == sy_club_venue_detail.sy_club.user)
    @permissions = user.try(:permissions, sy_club_venue_detail) || {}
  end

  def create?
    user&.super_admin? || user&.club_admin? || permissions[:country_admin] || is_club_creator
  end

  def update?
    create?
  end

  def destroy?
    user.super_admin?
  end
end
