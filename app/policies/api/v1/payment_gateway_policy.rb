class Api::V1::PaymentGatewayPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :payment_gateway
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, payment_gateway)
    @user = user
    @payment_gateway = payment_gateway
  end
  
  def show
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
