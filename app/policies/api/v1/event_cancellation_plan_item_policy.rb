class Api::V1::EventCancellationPlanItemPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :event_cancellation_plan_item
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_cancellation_plan_item)
    @user = user
    @event_cancellation_plan_item = event_cancellation_plan_item
  end

  def create?
    # if user is super admin or event admin
    user.present? and ( user.super_admin? or user.digital_store_admin? or user.india_admin? )
  end

  def show?
    # if user is super admin or event admin
    user.present? and ( user.super_admin? or user.digital_store_admin? or user.india_admin? )
  end
  
  def update?
    # if user is super admin or event admin
    user.present? and ( user.super_admin? or user.digital_store_admin? or user.india_admin? )
  end
  
  def destroy?
    # if user is super admin or event admin
    user.present? and ( user.super_admin? or user.digital_store_admin? or user.india_admin? )
  end
end
