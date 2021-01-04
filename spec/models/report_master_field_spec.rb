require 'rails_helper'

RSpec.describe ReportMasterField, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should have_many(:report_master_field_associations) }
    it { should have_many(:report_masters).through(:report_master_field_associations) }
  end

  describe "validations" do
    it { should validate_presence_of(:field_name) }
    it { should validate_uniqueness_of(:field_name).ignoring_case_sensitivity }
  end
end