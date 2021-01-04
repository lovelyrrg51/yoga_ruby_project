class BhandaraDetailPolicy < ApplicationPolicy
  attr_reader :bhandara_detail


  def initialize(user, bhandara_detail)
    @bhandara_detail = bhandara_detail
    super(user, bhandara_detail.try(:event))
  end

  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.created_events.include?(bhandara_detail.event) or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.created_events.include?(bhandara_detail.event) or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end
end
