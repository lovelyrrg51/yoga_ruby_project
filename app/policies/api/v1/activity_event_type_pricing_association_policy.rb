class Api::V1::ActivityEventTypePricingAssociationPolicy < Api::V1::ApplicationPolicy
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
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
  
  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
  
  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin? or user.event_admin?)
  end
end
