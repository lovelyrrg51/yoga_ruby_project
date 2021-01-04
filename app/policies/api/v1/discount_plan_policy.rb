class Api::V1::DiscountPlanPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :discount_plan
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, discount_plan)
    @user = user
    @discount_plan = discount_plan
  end
  
  def create?
    # if user is super admin or store admin or event admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
  
  def update?
    # if user is super admin or store admin or event admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
  
  def destroy?
    # if user is super admin or store admin or event admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
end
