class Api::V1::CcavenueConfigPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope
    end
  end
  
  def initialize(user, ccavenue_config)
    @user = user
    @ccavenue_config = ccavenue_config
  end
    
  def create?
    # if user is super admin or event admin or event organiser
    user.super_admin? or user.event_admin? or (user == event.creator_user)
  end
  
  def update?
    # if user is super admin or event admin or event organiser
     user.super_admin? or user.event_admin? or (user == event.creator_user)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.event_admin?
  end
end
