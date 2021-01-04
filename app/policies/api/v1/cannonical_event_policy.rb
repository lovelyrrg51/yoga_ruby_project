class Api::V1::CannonicalEventPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :cannonical_event
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, cannonical_event)
    @user = user
    @cannonical_event = cannonical_event
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
