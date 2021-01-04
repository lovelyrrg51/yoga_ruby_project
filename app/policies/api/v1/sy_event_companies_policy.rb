class Api::V1::SyEventCompaniesPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :sy_event_companies
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, sy_event_companies)
    @user = user
    @sy_event_companie = sy_event_companies
  end
    
  def create?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
  
  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
  
  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.club_admin?)
  end
end
