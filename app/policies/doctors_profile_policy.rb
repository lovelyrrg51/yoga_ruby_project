class DoctorsProfilePolicy < ApplicationPolicy
  attr_reader :user, :doctors_profile
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, doctors_profile)
    @user = user
    @doctors_profile = doctors_profile
  end
  
  def show?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == doctors_profile.sadhak_profile or user.sadhak_profiles.include?(doctors_profile.sadhak_profile)
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == doctors_profile.sadhak_profile or user.sadhak_profiles.include?(doctors_profile.sadhak_profile)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
end
