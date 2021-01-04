class Api::V1::SadhakProfilePolicy
  attr_reader :user, :sadhak_profile

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if user.present? and (user.super_admin? or user.india_admin?) 
        if filtering_params.nil?
          scope.all
        else
          scope.filter(filtering_params)
        end
      else
        if filtering_params.nil?
          scope.all
        else
          scope.filter(filtering_params)
        end
      end
    end
  end



  def initialize(user, sadhak_profile)
    @user = user
    @sadhak_profile = sadhak_profile
  end

  def show?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def update?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def generate_file?
    user.present? and user.super_admin?
  end

  def wp_sadhak_profile?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.india_admin? )
  end

  def upcoming_shivirs?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end

  def generate_card?
    # if user is super admin or its user's own sadhak profile or its one of the related members sadhak profile
    user and (user.super_admin? or user.sadhak_profile == sadhak_profile or user.sadhak_profiles.include?(sadhak_profile) or user.india_admin? )
  end
end
