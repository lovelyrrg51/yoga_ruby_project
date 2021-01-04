class Api::V1::EventAwarenessTypePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :event_awareness_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
   def initialize(user, event_awareness_type)
    @user = user
    @event_awareness_type = event_awareness_type
  end
  
  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
