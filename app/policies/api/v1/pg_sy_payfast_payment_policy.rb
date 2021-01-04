class Api::V1::PgSyPayfastPaymentPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :pg_sy_payfast_payment
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, pg_sy_payfast_payment)
    @user = user
    @pg_sy_payfast_payment = pg_sy_payfast_payment
  end
    
  def create?
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def update?
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def destroy?
    user.present? and (user.super_admin? or user.india_admin?)
  end
end
