class SpecialEventSadhakProfileOtherInfo < ApplicationRecord
  acts_as_paranoid

  attr_accessor :skip_validations

  belongs_to :sadhak_profile
  belongs_to :event_order_line_item
  belongs_to :event
  has_many :special_event_sadhak_profile_references
  has_many :sadhak_profiles, through: :special_event_sadhak_profile_references, source: :sadhak_profile
  accepts_nested_attributes_for :special_event_sadhak_profile_references, allow_destroy: true

  serialize :accepted_terms_and_conditions, Array

  scope :event_id, ->(event_id) { where event_id: event_id }
  scope :sadhak_profile_id, ->(sadhak_profile_id) { where sadhak_profile_id: sadhak_profile_id }

  validates :sadhak_profile_id, :event_id, :father_name, :mother_name, :how_long_associated_with_shivyog, :yearly_renumaration, :languages,  :why_you_want_to_attend_this_shivir, :how_did_you_came_to_know_about_the_shivir, presence: true, exclusion: { in: %w(NA N/A Na nA na n/a), case_sensitive: false, message: "%{value} is not a valid input." }

  validates_presence_of :political_party_name, if: :are_you_member_of_political_party?
  validates_presence_of :medication_details, if: :are_you_taking_medication?
  validates_presence_of :ailment_details, if: :are_you_suffering_from_physical_or_mental_ailments?
  validates_presence_of :case_details, if: :are_you_involved_in_any_litigation_cases?
  validates_presence_of :participation_details, if: :would_you_like_to_participate_in_the_devine_mission_of_shivyog?

  validates :accepted_terms_and_conditions, :signature, presence: true, on: :update, unless: :skip_validations
  validate :check_event_type

  private
  def check_event_type
    errors.add(:event, 'type must be Ashram Residential Shivirs.') unless self&.event&.is_ashram_residential_shivir?
    errors.empty?
  end
end
