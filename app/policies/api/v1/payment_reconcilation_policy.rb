class Api::V1::PaymentReconcilationPolicy < Api::V1::ApplicationPolicy
	attr_reader :user, :payment_reconcilation
  class Scope < Struct.new(:user, :scope)
    def resolve
    	# if user.present? and (user.super_admin? or user.india_admin?)
      	scope.all
      # end
    end
  end

  def initialize(user, payment_reconcilation)
    @user = user
    @payment_reconcilation = payment_reconcilation
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

  def reconcilation?
 		# if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end

  def generate_reconcilation_file?
	 	# if user is super admin or india admin
    user.present? and (user.super_admin? or user.india_admin?)
  end
end
