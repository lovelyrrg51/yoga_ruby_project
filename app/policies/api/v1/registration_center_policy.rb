class Api::V1::RegistrationCenterPolicy < Api::V1::ApplicationPolicy
  attr_reader :registration_center
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, registration_center)
    @registration_center = registration_center
    super(user, registration_center.try(:events).try(:last))
  end

  def create?
    # if user is super admin or store admin or india admin
    # user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
    true
  end

  def update?
    # if user is super admin or store admin or india admin
    user.present? && (user.super_admin? || user.event_admin? || user.india_admin? || permissions[:country_admin])
  end

  def destroy?
    update?
  end
end
