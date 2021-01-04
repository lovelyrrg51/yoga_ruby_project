class FrequentSadhnaType < ApplicationRecord
  has_many :spiritual_practice_frequent_sadhna_type_associations, dependent: :destroy
  has_many :spiritual_practices, through: :spiritual_practice_frequent_sadhna_type_associations

  validates_uniqueness_of :name, case_sensitive: false

  scope :sadhna_name, ->(sadhna_name) { where("name ILIKE ?", "%#{sadhna_name}%") }
end
