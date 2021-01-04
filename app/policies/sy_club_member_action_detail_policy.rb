# frozen_string_literal: true

class SyClubMemberActionDetailPolicy < ApplicationPolicy
  attr_reader :user, :sy_club_member_action_detail
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.present?
        scope.filter(filtering_params)
      elsif user&.super_admin? || user&.club_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, sy_club_member_action_detail)
    @user = user
    @sy_club_member_action_detail = sy_club_member_action_detail
  end

  def create?
    user&.super_admin? || user&.club_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
