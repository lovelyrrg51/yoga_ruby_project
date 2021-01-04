class SyClubMemberPolicy < ApplicationPolicy
  attr_reader :user, :sy_club_member
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k,v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, sy_club_member)
    @user = user
    @sy_club_member = sy_club_member
  end

  def create?
    user.super_admin? or user.club_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
