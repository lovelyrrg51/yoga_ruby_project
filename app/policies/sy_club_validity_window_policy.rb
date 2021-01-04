class SyClubValidityWindowPolicy < ApplicationPolicy
	attr_reader :user, :sy_club_validity_window
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_club_validity_window)
    @user = user
    @sy_club_validity_window = sy_club_validity_window
  end

  def index?
    # if user is super admin or store admin or uer.india_admin?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
  end

  def new?
    index?
  end

  def create?
    index?
  end

  def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    index?
  end
end
