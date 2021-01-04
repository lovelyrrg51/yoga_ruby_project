class Api::V1::AddressPolicy < Api::V1::ApplicationPolicy
  attr_reader :address
  class Scope < Struct.new(:user, :scope)
    def resolve
      # if user is super admin or store admin
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end

  def initialize(user, address)
    @address = address
    super(user, address.addressable)
  end

  def show?
    # if user is super admin or store admin
    user.present? and (user.super_admin? or user.digital_store_admin?)
  end

  def create?
    case address.addressable_type
    when 'SadhakProfile'
      true
    when 'Event'
      user.present? && (user.super_admin? || user.event_admin? || permissions[:country_admin] || (user.india_admin? && address.country_id == 113) || user.try(:is_country_admin?) || permissions[:per_event_admin])
    when 'SyClub'
      user.present? && (user.super_admin? || user.club_admin? || (user.india_admin? && address.country_id == 113) || permissions[:country_admin] || user.is_country_admin?)
    when 'SyEventCompany'
      user.present? && (user.super_admin? || user.india_admin? || (user.india_admin? && address.country_id == 113))
    else
      false
    end
  end

  def update?
    can_update = case address.addressable_type
    when 'SadhakProfile'
      true
    when 'Event'
      user.present? && (user.super_admin? || user.event_admin? || permissions[:country_admin] || (user.india_admin? && address.country_id == 113) || permissions[:per_event_admin])
    when 'SyClub'
      user.present? && (user.super_admin? || user.club_admin? || (user.india_admin? && address.country_id == 113) or permissions[:country_admin])
    when 'SyEventCompany'
      user.present? && (user.super_admin? || user.india_admin? || (user.india_admin? && address.country_id == 113))
    else
      false
    end
    can_update
  end

  def destroy?
    # if user is super admin or store admin
    user.present? && user.super_admin?
  end
end
