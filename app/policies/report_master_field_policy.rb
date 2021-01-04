# frozen_string_literal: true

class ReportMasterFieldPolicy < ApplicationPolicy
  attr_reader :user, :report_master_field
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, report_master_field)
    @user = user
    @report_master_field = report_master_field
  end

  def create?
    user&.super_admin?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end
end
