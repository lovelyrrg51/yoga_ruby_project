class PandalDetailPolicy < ApplicationPolicy
  attr_reader :pandal_detail


  def initialize(user, pandal_detail)
    @pandal_detail = pandal_detail
    super(user, pandal_detail.try(:event))
  end

  def create?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.created_events.include?(pandal_detail.event) or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def update?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.created_events.include?(pandal_detail.event) or user.india_admin?  or permissions[:country_admin] or permissions[:per_event_admin]
  end

  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin? or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin]
  end
end
