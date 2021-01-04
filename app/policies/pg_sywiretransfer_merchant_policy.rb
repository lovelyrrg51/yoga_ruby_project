# frozen_string_literal: true

class PgSywiretransferMerchantPolicy < ApplicationPolicy
  attr_reader :user, :pg_sywiretransfer_merchant
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sywiretransfer_merchant)
    @user = user
    @pg_sywiretransfer_merchant = pg_sywiretransfer_merchant
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
