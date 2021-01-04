class Api::V1::EventTypePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :event_type
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, event_type)
    @user = user
    @event_type = event_type
  end
  
  def create?
    # if user is super admin or store admin or india admin 
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
  
  def update?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
  
  def destroy?
    # if user is super admin or store admin or india admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
end
