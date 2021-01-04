# frozen_string_literal: true

class DbStatePolicy
  attr_reader :user, :db_state

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

  def initialize(user, db_state)
    @user = user
    @db_state = db_state
  end

  def show?
    true
  end

  def index_for_admin?
    user.super_admin? || user.digital_store_admin? || user.india_admin?
  end

  def new?
    index_for_admin?
  end

  def create?
    index_for_admin?
  end

  def edit?
    index_for_admin?
  end

  def update?
    index_for_admin?
  end

  def destroy?
    index_for_admin?
  end

  def state_index_for_city?
    index_for_admin?
  end

end
