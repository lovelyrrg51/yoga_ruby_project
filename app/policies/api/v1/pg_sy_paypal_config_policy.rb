class Api::V1::PgSyPaypalConfigPolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, pg_sy_paypal_config)
    @user = user
    @pg_sy_paypal_config = pg_sy_paypal_config
  end
    
  def create?
    # if user is super admin or event admin or event organiser
    user.super_admin? or user.event_admin?
  end
  
  def update?
    # if user is super admin or event admin or event organiser
    user.super_admin? or user.event_admin?
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
