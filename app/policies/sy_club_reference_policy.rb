# frozen_string_literal: true

class SyClubReferencePolicy < ApplicationPolicy
  attr_reader :user, :is_club_creator, :permissions
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, sy_club_reference)
    @user = user
    @is_club_creator = user == sy_club_reference.sy_club.user
    @permissions = user.try(:permissions, sy_club_reference) || {}
  end

  def create?
    user.super_admin? || user.club_admin? || permissions[:country_admin] || is_club_creator
  end

  def update?
    create?
  end

  def destroy?
    user.super_admin? || user.club_admin?
  end
end
