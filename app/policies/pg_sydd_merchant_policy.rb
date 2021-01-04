# frozen_string_literal: true

class PgSyddMerchantPolicy < ApplicationPolicy
  attr_reader :user, :pg_sydd_merchant
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sydd_merchant)
    @user = user
    @pg_sydd_merchant = pg_sydd_merchant
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
