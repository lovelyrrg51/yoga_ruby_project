# frozen_string_literal: true

class DbCountryPolicy
  attr_reader :user, :db_country

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |_, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, db_country)
    @user = user
    @db_country = db_country
  end

  def show?
    true
  end

  def index?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
  end

  def new?
    index?
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

  def country_index_for_state?
    index?
  end

  def country_index_for_state_city?
    index?
  end

end
