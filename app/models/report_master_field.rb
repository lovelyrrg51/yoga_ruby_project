class ReportMasterField < ApplicationRecord
  acts_as_paranoid

  validates :field_name, presence: true, uniqueness: {case_sensitive: false}

  has_many :report_master_field_associations
  has_many :report_masters, through: :report_master_field_associations
end
