class RegistrationCenterPolicy < ApplicationPolicy
  attr_reader :registration_center
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select!{|k,v| v.present?}
      if( filtering_params.present? )
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, registration_center)
    @registration_center = registration_center
    super(user, registration_center.try(:events).try(:last))
  end
  
  def new?

    permissions[:super_admin] || permissions[:event_admin] || india_admin
  
  end

  def index?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end

  def create?
    
    permissions[:super_admin] || permissions[:event_admin] || india_admin

  end

  def edit?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end

  def update?
    # if user is super admin or store admin or india admin
    user.present? && (user.super_admin? || user.event_admin? || user.india_admin? || permissions[:country_admin])
  end

  def destroy?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end
  
  def destroy?
    
    permissions[:super_admin] || permissions[:event_admin] || india_admin

  end

   def index_for_admin?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end
  
  def new_for_admin?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end

  def create_for_admin?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end

  def edit_for_admin?
    # if user is super admin or store admin or india admin  
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end
  
  def update_for_admin?
    # if user is super admin or store admin or india admin 
    user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end
  
  def destroy_for_admin?
    # if user is super admin or store admin or india admin
     user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin?
  end
end
