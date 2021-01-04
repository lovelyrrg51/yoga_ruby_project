module Api::V1
  class EventSerializer < ActiveModel::Serializer

    attributes :id, :event_name, :event_start_date, :event_end_date, :creator_user_id, :event_proposal_id, :daily_start_time, :daily_start_time, :payment_category, :total_capacity, :contact_email, :description, :graced_by, :contact_details, :video_url, :demand_draft_instructions, :status, :cannonical_event_id, :website, :event_type_id, :additional_details, :event_start_time, :event_end_time, :is_photo_proof_required, :show_seats_availability, :event_location, :status_changes_notes, :is_club_event, :pre_approval_required, :registrations_recipients, :show_shivir_price, :full_profile_needed, :pay_in_usd, :entity_type, :entity_key, :discount_plan_id, :event_cancellation_plan_id, :automatic_refund, :reference_event_id, :sy_event_company_id, :has_seva_preference, :approver_email, :logistic_email, :end_date_ignored, :prerequisite_message, :notification_service, :shivir_card_enabled, :discount_text



    #embed :ids
    has_one :attachment, include: true
    has_one :address, include: true
  #   has_many :tickets, include: true
    has_many :event_cost_estimations, include: true
    has_many :event_seating_category_associations, include: true
    has_many :event_awarenesses, include: true
    has_one  :pandal_detail, include: true
    has_one  :bhandara_detail, include: true
    has_many :event_tax_type_associations, include: true
    has_many :event_team_details, include: true
    has_one :event_type, include: true
  #   has_many :event_registration_center_associations, include: true
    has_many :registration_centers, include: true
  #   has_many :event_registrations, include: true
    #has_many :event_orders#, include: true
    has_one :venue_type, include: true
    has_many :ds_shops
    has_many :payment_gateways
    has_one :handy_attachment, include: true
    has_many :prerequisite_events
    has_many :event_types
    # has_many :event_type_pricings, include: true

  end
end
