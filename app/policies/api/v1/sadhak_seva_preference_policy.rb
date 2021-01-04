class Api::V1::SadhakSevaPreferencePolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :sadhak_seva_preference
  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.super_admin? or user.digital_store_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, sadhak_seva_preference)
    @user = user
    @sadhak_seva_preference = sadhak_seva_preference
  end
  
  def show?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
  
  def create?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == sadhak_seva_preference.sadhak_profile or user.sadhak_profiles.include?(sadhak_seva_preference.sadhak_profile)
  end
  
  def update?
    # if user is super admin or store admin or sadhak profile of details belongs to current user
    user.super_admin? or user.digital_store_admin? or user.sadhak_profile == sadhak_seva_preference.sadhak_profile or user.sadhak_profiles.include?(sadhak_seva_preference.sadhak_profile)
  end
  
  def destroy?
    # if user is super admin or store admin
    user.super_admin? or user.digital_store_admin?
  end
end
