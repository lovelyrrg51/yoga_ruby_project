# frozen_string_literal: true

class PgSywiretransferTransactionPolicy < ApplicationPolicy
  attr_reader :user, :pg_sywiretransfer_transaction
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sywiretransfer_transaction)
    @user = user
    @pg_sywiretransfer_transaction = pg_sywiretransfer_transaction
  end

  def create?
    user.super_admin?
  end

  def update?
    user.super_admin?
  end

  def destroy?
    user.super_admin?
  end
end
