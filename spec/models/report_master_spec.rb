require 'rails_helper'

RSpec.describe ReportMaster, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should have_many(:report_master_field_associations) }
    it { should have_many(:report_master_fields).through(:report_master_field_associations) }
  end

  describe "validations" do
    it { should validate_presence_of(:report_name) }
    it { should validate_uniqueness_of(:report_name).ignoring_case_sensitivity }
  end

  it { should serialize(:required_params) }
end