class AdminPolicy < ApplicationPolicy
  attr_reader :user, :admin

  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def registration_invoices?
    user&.super_admin?
  end

  def photo_approval_admin_panel?
    user&.super_admin? || user.event_admin? || user.photo_approval_admin?
  end

  def export_photo_approval_list?
    photo_approval_admin_panel?
  end

  def merge_syid?
    user&.super_admin?
  end

  def match_merge_syid?
    merge_syid?
  end

  def users_associated_with_provider?
    user&.super_admin?
  end

  def change_users_associated_with_provider?
    user&.super_admin?
  end

  def event_types?
    user&.super_admin?
  end

  def seating_categories?
    user&.super_admin?
  end

  def frequent_sadhna_types?
    user&.super_admin?
  end

  def physical_exercise_types?
    user&.super_admin?
  end

  def shivyog_teachings?
    user&.super_admin?
  end

  def ticket_groups?
    user&.super_admin?
  end

  def ticket_types?
    user&.super_admin?
  end

  def professions?
    user&.super_admin?
  end

  def venue_types?
    user&.super_admin?
  end

  def medical_practitioner_speciality_areas?
    user&.super_admin?
  end

  def address_proof_types?
    user&.super_admin?
  end

  def photo_id_types?
    user&.super_admin?
  end

  def sy_event_companies?
    user&.super_admin?
  end

  def payment_gateway_types?
    user&.super_admin?
  end

  def payment_modes?
    user&.super_admin?
  end

  def tax_types?
    user&.super_admin?
  end

  def dashboard_widget_configs?
    user&.super_admin?
  end

  def sy_club_validity_windows?
    user&.super_admin?
  end

  def event_cancellation_plans?
    user&.super_admin?
  end

  def discount_plans?
    user&.super_admin?
  end

  def source_info_types?
    user&.super_admin?
  end

  def db_countries?
    user&.super_admin?
  end

  def db_states?
    user&.super_admin?
  end

  def db_cities?
    user&.super_admin?
  end

  def global_preferences?
    user&.super_admin?
  end

  def registration_centers?
    user&.super_admin?
  end

  def authorizations?
    user&.super_admin?
  end

  def search_sadhak?
    user&.super_admin?
  end

  def offline_forum_data_migration?
    user&.super_admin?
  end

  def restore_sadhak_profile?
    user&.super_admin?
  end

  def deleted_sadhak_profiles?
    user&.super_admin?
  end

  def sadhaks_episodes?
    user&.super_admin?
  end

end
