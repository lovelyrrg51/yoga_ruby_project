# frozen_string_literal: true

class SourceInfoTypePolicy < ApplicationPolicy
  attr_reader :user, :source_info_type
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      filtering_params.select! { |k,v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

  def initialize(user, source_info_type)
    @user = user
    @source_info_type = source_info_type
  end

  def index?
    user&.super_admin? or user.india_admin?
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

  def show?
  	index?
  end
end
