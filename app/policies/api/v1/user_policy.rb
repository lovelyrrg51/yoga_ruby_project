class Api::V1::UserPolicy
  attr_reader :user, :digital_asset

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.present? and (user.super_admin? or user.digital_store_admin? or user.india_admin?)
        scope.all
      end
    end
  end
  
  def initialize(user)
    @user = user
  end
  
  def index?
     user.present? and (user.super_admin? or user.digital_store_admin?  or user.group_admin? or user.india_admin?)
  end
  
  def show?
     user.present? and (user.super_admin? or user.digital_store_admin?  or user.group_admin? or user.india_admin?)
  end
  
  def create?
    user.present? and (user.super_admin? or user.india_admin? or user.digital_store_admin?)
  end
  
  def update?
    user.present? and (user.super_admin? or user.india_admin? or user.digital_store_admin?)
  end
  
  def destroy?
    user.present? and (user.super_admin? or user.india_admin? or user.digital_store_admin?)
  end
  
  def reset_sadhak_password?
    user.present? and (user.super_admin? or user.is_country_admin?)
  end

  def wp_reset_password?
    user.present? and (user.super_admin? or user.india_admin? or user.event_admin? or user.club_admin?)
  end

  def update_password?
    user.present?
  end

end
