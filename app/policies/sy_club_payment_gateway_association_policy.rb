class SyClubPaymentGatewayAssociationPolicy < ApplicationPolicy
  attr_reader :user, :sy_club_payment_gateway_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, sy_club_payment_gateway_association)
    @user = user
    @sy_club_payment_gateway_association = sy_club_payment_gateway_association
  end

  def create?
    user&.super_admin? || user&.club_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
