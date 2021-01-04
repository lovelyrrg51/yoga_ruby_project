class ReportMasterPolicy < ApplicationPolicy
  attr_reader :user, :report_master
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = nil)
      if filtering_params.nil?
        scope.all
      else
        scope.filter(filtering_params)
      end
    end
  end

  def initialize(user, report_master)
    @user = user
    @report_master = report_master
  end

  def create?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end

  def update?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end

  def destroy?
    # if user is super admin or club admin
    user.present? and (user.super_admin?)
  end

  def generate_report?
    user.present? and (user.super_admin? or user.event_admin? or permissions[:per_event_admin] or permissions[:country_admin])
  end
end
