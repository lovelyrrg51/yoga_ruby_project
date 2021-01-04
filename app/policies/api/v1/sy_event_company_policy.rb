class Api::V1::SyEventCompanyPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :sy_event_company
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_event_company)
    @user = user
    @sy_event_company = sy_event_company
  end
    
  def create?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end
  
  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end
  
  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end

  def show?
    # if user is super admin or club admin
    true
  end
end
