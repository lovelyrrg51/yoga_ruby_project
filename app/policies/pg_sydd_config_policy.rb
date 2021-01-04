# frozen_string_literal: true

class PgSyddConfigPolicy < ApplicationPolicy
  attr_reader :user, :pg_sydd_config
  class Scope < Struct.new(:user, :scope)
    def resolve
      scope.all
    end
  end

  def initialize(user, pg_sydd_config)
    @user = user
    @pg_sydd_config = pg_sydd_config
  end

  def index?
    user.super_admin? || user.event_admin?
  end

   def create?
    index?
  end

   def edit?
    index?
  end

  def update?
    index?
  end

  def destroy?
    user.super_admin? || user.digital_store_admin?
  end

end
