class Api::V1::EventPolicy < Api::V1::ApplicationPolicy
  attr_reader :event
  class Scope < Struct.new(:user, :scope)
    def resolve(filtering_params = {})
      filtering_params.select! { |k, v| v.present? }
      if filtering_params.present?
        scope.filter(filtering_params)
      else
        scope.none
      end
    end
  end

#   def show?
#     user.super_admin? or user.digital_store_admin?
#   end

  def initialize(user, event)
    @event = event
    super
  end

  def create?
    # if user is super admin or store admin or event_admin or creator or india admin
    user.present? && (user.super_admin? or user.digital_store_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or user.is_country_admin?)
  end

  def update?
    # if user is super admin or store admin or event_admin or creator  or india admin
    user.present? and (user.super_admin? or user.digital_store_admin? or user.event_admin? or (user == event.creator_user) or user.club_admin? or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin])
  end

  def destroy?
    # if user is super admin or store admin or india admin
    user.present? and (user.super_admin? or user.digital_store_admin?  or user.india_admin?)
  end

  def bulk_upload?
    user.present? and (user.super_admin? or user.event_admin? or user.india_admin? or permissions[:country_admin] or permissions[:per_event_admin])
  end

  def forum_event?
    # if user is super admin or store admin or event_admin or creator
    user.present? and (user.super_admin? or user.event_admin? or user.club_admin? or user.india_admin?)
  end

  def registration_changes_report?
    user.present? and (user.super_admin? or user.event_admin?)
  end

  def events_excel?
    user.present? and (user.super_admin? or user.event_admin?)
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
    
  def update_ashram_residential_shivirs_dates?
    user.present? && user.super_admin?
  end

end
