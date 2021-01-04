class Api::V1::PgSywiretransferTransactionPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :pg_sywiretransfer_transaction
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end
  
  def initialize(user, pg_sywiretransfer_transaction)
    @user = user
    @pg_sywiretransfer_transaction = pg_sywiretransfer_transaction
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
