class MergeSadhak < ApplicationRecord
  serialize :meta_data, JSON

  belongs_to :primary_sadhak, class_name: 'SadhakProfile', foreign_key: :primary_sadhak_id
  belongs_to :secondary_sadhak, class_name: 'SadhakProfile', foreign_key: :secondary_sadhak_id
  belongs_to :user
  has_one :sadhak_profile, through: :user

  delegate :syid, to: :sadhak_profile, allow_nil: true
  delegate :full_name, to: :sadhak_profile, allow_nil: true
end
