# frozen_string_literal: true

class PgSyPayfastConfigPolicy < ApplicationPolicy
  attr_reader :user, :pg_sy_payfast_config
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, pg_sy_payfast_config)
    @user = user
    @pg_sy_payfast_config = pg_sy_payfast_config
  end

  def index?
    user&.super_admin? || user&.india_admin?
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
    index?
  end
end
