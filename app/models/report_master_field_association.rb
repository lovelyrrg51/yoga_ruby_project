class ReportMasterFieldAssociation < ApplicationRecord
  acts_as_paranoid

  validates :report_master_id, :report_master_field_id, presence: true
  validates_uniqueness_of :report_master_field_id, scope: :report_master_id

  belongs_to :report_master
  belongs_to :report_master_field

  scope :report_master_id, lambda { |report_master_id| where(report_master_id: report_master_id) }
  scope :report_master_field_id, lambda { |report_master_field_id| where(report_master_field_id: report_master_field_id) }

  def self.includable_data
    [:report_master_field]
  end

  def update_proc_block(&block)
    raise 'Block is missing.' unless block.present?
    self.update_columns(proc_block: block.to_raw_source)
  end

  def update_proc_block=(block)
    raise 'Block is missing.' unless block.present?
    self.update_columns(proc_block: block.to_raw_source)
  end
end
