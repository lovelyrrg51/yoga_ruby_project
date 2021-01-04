class EventReferencePolicy < ApplicationPolicy
  attr_reader :event_reference, :is_event_creator
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_reference)
    @event_reference = event_reference
    @is_event_creator = (user == event_reference.event.creator_user)
    super(user, event_reference.try(:event))
  end

  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or is_event_creator or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or is_event_creator or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.india_admin?
  end
end
