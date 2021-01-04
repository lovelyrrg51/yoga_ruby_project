class TransactionLogPolicy < ApplicationPolicy
  attr_reader :user, :transaction_log
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, transaction_log)
    @user = user
    @transaction_log = transaction_log
  end

  def create?
    user&.super_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
