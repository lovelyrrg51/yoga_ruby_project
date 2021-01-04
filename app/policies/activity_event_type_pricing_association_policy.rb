class ActivityEventTypePricingAssociationPolicy < ApplicationPolicy
  attr_reader :user, :activity_event_type_pricing_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end
  
  def initialize(user, activity_event_type_pricing_association)
    @user = user
    @activity_event_type_pricing_association = activity_event_type_pricing_association
  end

  def create?
    user&.super_admin? || user&.event_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
