class Api::V1::PaymentGatewayTypePolicy < Api::V1::ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, payment_gateway_type)
    @user = user
    @payment_gateway_type = payment_gateway_type
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
