class Api::V1::EventDiscountPlanAssociationPolicy < Api::V1::ApplicationPolicy
 	attr_reader :user, :event_discount_plan_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end

  def initialize(user, event_discount_plan_association)
    @user = user
    @event_discount_plan_association = event_discount_plan_association
  end

  def create?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin?or user.event_admin? or user.india_admin? 
  end
  
  def update?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin?or user.event_admin? or user.india_admin? 
  end
  
  def destroy?
    # if user is super admin or store admin or india admin 
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin? 
  end
end
