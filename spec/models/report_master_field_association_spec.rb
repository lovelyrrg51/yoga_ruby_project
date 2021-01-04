require 'rails_helper'

RSpec.describe ReportMasterFieldAssociation, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:report_master) }
    it { should belong_to(:report_master_field) }
  end

  describe "validations" do
    it { should validate_presence_of(:report_master_id) }
    it { should validate_presence_of(:report_master_field_id) }
    it { should validate_uniqueness_of(:report_master_field_id).scoped_to(:report_master_id) }
  end
end