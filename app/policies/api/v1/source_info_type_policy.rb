class Api::V1::SourceInfoTypePolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :source_info_type
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      return filtering_params.nil? ? scope.all : scope.filter(filtering_params)
    end
  end

  def initialize(user, source_info_type)
    @user = user
    @source_info_type = source_info_type
  end
    
  def create?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def update?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
  
  def destroy?
    # if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end

  def show?
  	# if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
end
