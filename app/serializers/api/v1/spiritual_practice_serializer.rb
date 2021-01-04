module Api::V1
  class SpiritualPracticeSerializer < ActiveModel::Serializer
    attributes :id, :morning_sadha_duration_hours, :afternoon_sadha_duration_hours, :evening_sadha_duration_hours, :other_sadha_duration_hours, :sadhana_frequency_days_per_week, :frequency_period, :frequent_sadhana_type, :physical_exercise_type, :shivyog_teachings_applied_in_life, :sadhak_profile_id
    #embed :ids
    has_many :frequent_sadhna_types
    has_many :physical_exercise_types
    has_many :shivyog_teachings
    #has_one :user
    #has_one :sadhak_profile
  end
end
