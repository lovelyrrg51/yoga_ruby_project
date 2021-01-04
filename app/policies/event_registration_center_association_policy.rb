class EventRegistrationCenterAssociationPolicy < ApplicationPolicy
  attr_reader :event_registration_center_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, event_registration_center_association)
    @event_registration_center_association = event_registration_center_association
    super(user, event_registration_center_association.try(:event))
  end

  def create?
    # if user is super admin or store admin or user.india_admin?
    user.present? && (user.super_admin? || user.india_admin? || permissions[:country_admin] || permissions[:per_event_admin])
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
