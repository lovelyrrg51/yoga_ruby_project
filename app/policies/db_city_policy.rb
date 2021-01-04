# frozen_string_literal: true

class DbCityPolicy
  attr_reader :user, :db_city

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

  def initialize(user, db_city)
    @user = user
    @db_city = db_city
  end

  def show?
    true
  end

  def new?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
  end

  def index_for_admin?
    new?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end

end
