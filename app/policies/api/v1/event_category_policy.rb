# class Api::V1::EventCategoryPolicy < Api::V1::ApplicationPolicy
#   attr_reader :user, :event_category
#   class Scope < Struct.new(:user, :scope)
#     def resolve
#       scope.all
#     end
#   end
  
#   def initialize(user, event_category)
#     @user = user
#     @event_category = event_category
#   end
  
#   def create?
#     # if user is super admin or store admin
#     user.super_admin? or user.digital_store_admin?
#   end
  
#   def update?
#     # if user is super admin or store admin
#     user.super_admin? or user.digital_store_admin?
#   end
  
#   def destroy?
#     # if user is super admin or store admin
#     user.super_admin? or user.digital_store_admin?
#   end
# end
