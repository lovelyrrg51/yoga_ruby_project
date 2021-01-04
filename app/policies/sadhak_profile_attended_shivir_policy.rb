class SadhakProfileAttendedShivirPolicy < ApplicationPolicy
  attr_reader :user, :sadhak_profile_attended_shivir, :sadhak_profile
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.present?
        scope.filter(filtering_params)
      elsif user.present? and user.super_admin?
        scope.all
      else
        []
      end
    end
  end
  
  def initialize(user, sadhak_profile_attended_shivir)
    @user = user
    @sadhak_profile_attended_shivir = sadhak_profile_attended_shivir
    @sadhak_profile = @sadhak_profile_attended_shivir.sadhak_profile
  end
    
  def create?
    # if user is super admin or related to sadhak_profile
    user.present? and (user.super_admin? or (user.sadhak_profile == sadhak_profile and user.sadhak_profiles.include?(sadhak_profile)))
  end
  
  def update?
    # if user is super admin or related to sadhak_profile
    user.present? and (user.super_admin? or (user.sadhak_profile == sadhak_profile and user.sadhak_profiles.include?(sadhak_profile)))
  end
  
  def destroy?
    # if user is super admin or related to sadhak_profile
    user.present? and (user.super_admin? or (user.sadhak_profile == sadhak_profile and user.sadhak_profiles.include?(sadhak_profile)))
  end
end
