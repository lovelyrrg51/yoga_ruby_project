# frozen_string_literal: true

class SyClubSadhakProfileAssociationPolicy < ApplicationPolicy
  attr_reader :user, :is_club_creator, :permissions
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_club_sadhak_profile_association)
    @user = user
    @is_club_creator = user == sy_club_sadhak_profile_association.sy_club.user
    @permissions = user.try(:permissions, sy_club_sadhak_profile_association) || {}
  end

  def create?
    user&.super_admin? || user&.club_admin? || permissions[:country_admin] || is_club_creator
  end

  def update?
    create?
  end

  def destroy?
    user&.super_admin? || user&.club_admin?
  end
end
