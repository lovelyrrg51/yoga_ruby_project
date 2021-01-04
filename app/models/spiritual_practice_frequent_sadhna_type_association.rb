class SpiritualPracticeFrequentSadhnaTypeAssociation < ApplicationRecord
  acts_as_paranoid
  belongs_to :spiritual_practice
  belongs_to :frequent_sadhna_type
end
