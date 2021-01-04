class Api::V1::TransactionLogPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :transaction_log
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, transaction_log)
    @user = user
    @transaction_log = transaction_log
  end
    
  def create?
    # if user is super admin
    user.present? and user.super_admin?
  end
  
  def update?
    # if user is super admin
    user.present? and user.super_admin?
  end
  
  def destroy?
    # if user is super admin
    user.present? and user.super_admin?
  end
end
