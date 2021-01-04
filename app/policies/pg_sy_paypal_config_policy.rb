# frozen_string_literal: true

class PgSyPaypalConfigPolicy < ApplicationPolicy
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sy_paypal_config)
    @user = user
    @pg_sy_paypal_config = pg_sy_paypal_config
  end

  def index?
    # if user is super admin or event admin or event organiser
    user.super_admin? || user.event_admin?
  end

  def create?
    index?
  end

  def eit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    user.super_admin? || user.digital_store_admin?
  end
end
