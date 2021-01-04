# frozen_string_literal: true

class ReportMasterFieldAssociationPolicy < ApplicationPolicy
  attr_reader :user, :report_master_field_association
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.all
      end
    end
  end

  def initialize(user, report_master_field_association)
    @user = user
    @report_master_field_association = report_master_field_association
  end

  def create?
    user&.super_admin?
  end

  def update?
    user&.super_admin?
  end

  def destroy?
    user&.super_admin?
  end
end
