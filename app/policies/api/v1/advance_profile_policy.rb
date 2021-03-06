class Api::V1::AdvanceProfilePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :advance_profile
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.photo_approval_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, advance_profile)
    @user = user
    @advance_profile = advance_profile
  end
  
  def show?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.india_admin?)
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    # user.super_admin? or user.digital_store_admin? or user.sadhak_profile == advance_profile.sadhak_profile or user.sadhak_profiles.include?(advance_profile.sadhak_profile)
    true
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.present? and (user.super_admin? or user.digital_store_admin? or user.sadhak_profile == advance_profile.sadhak_profile or user.sadhak_profiles.include?(advance_profile.sadhak_profile) or user.india_admin?)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.india_admin?)
  end
end
