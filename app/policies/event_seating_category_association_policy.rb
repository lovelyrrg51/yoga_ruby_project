class EventSeatingCategoryAssociationPolicy < ApplicationPolicy
  attr_reader :event_seating_category_association
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, event_seating_category_association)
    @event_seating_category_association = event_seating_category_association
    super(user, event_seating_category_association.try(:event))
  end

  def show?
    true
  end

  def create?
    user.present? && (user.super_admin? || user.event_admin? || user.india_admin? || permissions[:country_admin] || user.created_events.include?(event_seating_category_association.event) || permissions[:per_event_admin])
  end


  def update?
    create?
  end

  def destroy?
    create?
  end
end
