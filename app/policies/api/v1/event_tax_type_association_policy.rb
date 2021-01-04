class Api::V1::EventTaxTypeAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :event_tax_type_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, event_tax_type_association)
    @event_tax_type_association = event_tax_type_association
    super(user, event_tax_type_association.try(:event))
  end

  def create?
    user.present? && (user.super_admin? || user.event_admin? || user.india_admin? || user.created_events.include?(event_tax_type_association.event) || permissions[:country_admin] || permissions[:per_event_admin])
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

end
