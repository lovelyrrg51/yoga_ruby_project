class UserPolicy
  attr_reader :user, :digital_asset

  class Scope < Struct.new(:user, :scope)
    def resolve
      if user.present? and (user.super_admin? or user.digital_store_admin? or user.india_admin?)
        scope.all
      end
    end
  end

  def initialize(user, _)
    @user = user
  end

  def index?
     user&.super_admin? || user&.digital_store_admin? || user&.group_admin? || user&.india_admin?
  end

  def show?
    index?
  end

  def create?
    user&.super_admin? || user&.india_admin? || user&.digital_store_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def reset_sadhak_password?
    user&.super_admin? || user&.india_admin? || user&.is_country_admin?
  end

  def wp_reset_password?
    user&.super_admin? || user&.india_admin? || user&.event_admin? || user&.club_admin?
  end

  def edit?
    user.present?
  end

  def update_password?
    edit?
  end
end
