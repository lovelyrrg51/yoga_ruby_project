RSpec.describe AdminPolicy, type: :policy do
  subject { described_class }

  permissions :registration_invoices?, :merge_syid?, :match_merge_syid?,
    :users_associated_with_provider?, :change_users_associated_with_provider?,
    :event_types?, :seating_categories?, :frequent_sadhna_types?,
    :physical_exercise_types?, :shivyog_teachings?, :ticket_groups?,
    :ticket_types?, :professions?, :venue_types?, :medical_practitioner_speciality_areas?,
    :address_proof_types?, :photo_id_types?, :sy_event_companies?,
    :payment_gateway_types?, :payment_modes?, :tax_types?,
    :dashboard_widget_configs?, :sy_club_validity_windows?,
    :event_cancellation_plans?, :discount_plans?, :source_info_types?,
    :db_countries?, :db_states?, :db_cities?, :global_preferences?,
    :registration_centers?, :authorizations?, :search_sadhak?,
    :offline_forum_data_migration?, :restore_sadhak_profile?,
    :deleted_sadhak_profiles? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super_admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
