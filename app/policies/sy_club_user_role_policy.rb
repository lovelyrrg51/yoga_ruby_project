class SyClubUserRolePolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  def initialize(user, sy_club_user_role)
    @user = user
    @sy_club_user_role = sy_club_user_role
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin?
  end

  def destroy?
    user.super_admin?
  end
end
