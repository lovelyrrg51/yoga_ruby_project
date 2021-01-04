class Api::V1::PgSyddMerchantPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :pg_sydd_merchant
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, pg_sydd_merchant)
    @user = user
    @pg_sydd_merchant = pg_sydd_merchant
  end
  
  def create?
    # if user is super admin
    user.super_admin? 
  end
  
  def update?
    # if user is super admin
    user.super_admin?
  end
  
  def destroy?
    # if user is super admin
    user.super_admin?
  end
end
