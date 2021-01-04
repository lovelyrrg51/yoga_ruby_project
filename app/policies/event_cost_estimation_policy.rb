class EventCostEstimationPolicy < ApplicationPolicy
  attr_reader :user, :event_cost_estimation
  
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, event_cost_estimation)
    @user = user
    @event_cost_estimation = event_cost_estimation
  end
  
  def create?
    EventPolicy.new(user, event_cost_estimation.event).create?
  end
    
  def update?
    # if user is super admin or store admin
    EventPolicy.new(user, event_cost_estimation.event).update?
  end
  
  def destroy?
    # if user is super admin or store admin
    EventPolicy.new(user, event_cost_estimation.event).destroy?
  end
end
