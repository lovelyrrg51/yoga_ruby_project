class Api::V1::PgSyddConfigPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :pg_sydd_config
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, pg_sydd_config)
    @user = user
    @pg_sydd_config = pg_sydd_config
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
    user.super_admin? or user.digital_store_admin?
  end
  
end
