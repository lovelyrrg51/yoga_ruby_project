class EventPolicy < ApplicationPolicy

  attr_reader :event

  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.all
      end
    end
  end

  def initialize(user, event)
    super
    @event = event
  end

  def create?
    # if user is super admin or store admin or event_admin or creator or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or (user == event.creator_user) or user.india_admin? or permissions[:country_admin] or user.is_country_admin?)
  end

  def show?
    user.present? && (user.super_admin? || user.event_admin? || user.india_admin?)
  end

  def update?
    # if user is super admin or store admin or event_admin or creator  or india admin
    user.present? && (user.super_admin? || user.event_admin? || (user == event.creator_user) || user.india_admin? || permissions[:country_admin] or permissions[:per_event_admin])
  end

  def destroy?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin?  or user.india_admin? or permissions[:per_event_admin])
  end

  def bulk_upload?
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin])
  end

  def forum_event?
    # if user is super admin or store admin or event_admin or creator
    user.present? and (user.super_admin? or user.event_admin? or user.club_admin? or user.india_admin?)
  end

  def registration_changes_report?
    user.present? and (user.super_admin? or user.event_admin?)
  end

  def events_excel?
    user.present? and (user.super_admin?)
  end

  def i_card?
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin?)
  end

  def replicate?
    user.present? and event.present? and (user.super_admin? or user.event_admin? or user.india_admin?)
  end

  def by_gender?
    user.present? and (user.super_admin? or (user.india_admin? and @event.address.present? and @event.address.country_id == 113) or user.event_admin?)
  end

  def by_category?
    by_gender?
  end


  def by_mode_of_payment?
    by_gender?
  end

  def by_profession?
    by_gender?
  end

  def by_category_and_mode_of_payment?
    by_gender?
  end

  def payment_info?
    by_gender?
  end

  def payment_info_by_rc?
    by_gender?
  end

  def by_age_group?
    by_gender?
  end

  def by_previous_events_registered?
    by_gender?
  end

  def index?
    permissions[:super_admin] || permissions[:event_admin] || permissions[:india_admin]
  end

  def photo_approval?
    permissions[:super_admin] || permissions[:event_admin] || permissions[:photo_approval_admin] || permissions[:photo_approval_user] || india_admin
  end

  def export_photo_approval_list?
    photo_approval?
  end

  def photo_approval_admin?
    permissions[:super_admin] || permissions[:event_admin] || permissions[:photo_approval_admin] || india_admin
  end

  def registration_status?
    permissions[:super_admin] || permissions[:event_admin] || india_admin || rc
  end
  
  def registration_change?
    !@event.automatic_refund? && permissions[:super_admin]
  end

  def transaction?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end
	
  def report?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def registration_center_admin?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def registration_invoices?
    permissions[:super_admin] || permissions[:event_admin] || india_admin || rc
  end

  def application_status?
    @event.pre_approval_required? && (permissions[:super_admin] || permissions[:event_admin])
  end

  def shivir_details?
     permissions[:super_admin] || permissions[:event_admin] || india_admin || rc
  end 

  def tax_type?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def registration_discount_plan?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def additional_details?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def proposed_category?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def registration_cancelation_policy?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def edit_discount_plan?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end

  def event_status_update?
    permissions[:super_admin] || permissions[:event_admin] || india_admin
  end
  
end
