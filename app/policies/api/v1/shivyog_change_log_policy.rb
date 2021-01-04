class Api::V1::ShivyogChangeLogPolicy < Api::V1::ApplicationPolicy
  attr_reader :user, :shivyog_change_log
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if user.present? and user.super_admin? 
        if filtering_params.nil?
          scope.all
        else
          scope.filter(filtering_params)
        end
      else
        []
      end
    end
  end
  
  def initialize(user, shivyog_change_log)
    @user = user
    @shivyog_change_log = shivyog_change_log
  end
  
  def create?
    # if user is super admin or event admin or india admin
    user.super_admin? or user.event_admin? or user.india_admin?
  end
  
  def update?
    # if user is super admin or event admin or india admin
    user.super_admin? or user.event_admin? or user.india_admin?
  end
  
  def destroy?
    # if user is super admin or event admin or india admin
    user.super_admin? or user.event_admin? or user.india_admin?
  end
  
end
