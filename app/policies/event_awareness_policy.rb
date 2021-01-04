class EventAwarenessPolicy < ApplicationPolicy
  attr_reader :user, :event_awareness
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, event_awareness)
    @user = user
    @event_awareness = event_awareness
  end
  
  def create?
   # if user has authorization to create event
   EventPolicy.new(user, event_awareness.event).create?
  end
  
  def update?
    # if user has authorization to update event
    EventPolicy.new(user, event_awareness.event).update?
  end
  
  def destroy?
    # if user has authorization to destroy event
    EventPolicy.new(user, event_awareness.event).destroy?
  end
end
