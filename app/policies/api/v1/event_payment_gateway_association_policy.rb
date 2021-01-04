class Api::V1::EventPaymentGatewayAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :event_payment_gateway_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
   def initialize(user, event_payment_gateway_association)
    @user = user
    @event_payment_gateway_association = event_payment_gateway_association
  end

  def create?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
  
  def update?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
  
  def destroy?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?)
  end
end
