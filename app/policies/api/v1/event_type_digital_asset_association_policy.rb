class Api::V1::EventTypeDigitalAssetAssociationPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :event_type_digital_asset_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, event_type_digital_asset_association)
    @user = user
    @event_type_digital_asset_association = event_type_digital_asset_association
  end

  def show
    # if user is super admin or club admin or digital store admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
    
  def create?
    # if user is super admin or club admin or digital store admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def update?
    # if user is super admin or club admin or digital store admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
  
  def destroy?
    # if user is super admin or club admin or digital store admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.club_admin?)
  end
end
