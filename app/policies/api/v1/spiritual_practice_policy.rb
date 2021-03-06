class Api::V1::SpiritualPracticePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :spiritual_practice
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, spiritual_practice)
    @user = user
    @spiritual_practice = spiritual_practice
  end
  
  def show?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == spiritual_practice.sadhak_profile or user.sadhak_profiles.include?(spiritual_practice.sadhak_profile)
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == spiritual_practice.sadhak_profile or user.sadhak_profiles.include?(spiritual_practice.sadhak_profile)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
