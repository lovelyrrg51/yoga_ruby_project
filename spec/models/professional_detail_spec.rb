require 'rails_helper'

RSpec.describe ProfessionalDetail, type: :model do

  let(:professional_detail) { Class.new }

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:profession) }
  end

  # describe "validation" do
  #   sadhak_profile = SadhakProfile.count > 0 ? SadhakProfile.last : SadhakProfile.create(first_name: "test", last_name: "test", date_of_birth: "1980-03-05", gender: "male", user_id: 98)
  #   subject {FactoryBot.build(:professional_detail, sadhak_profile_id: sadhak_profile.id)}
  #   it { should validate_uniqueness_of(:sadhak_profile_id) }
  # end

  it do
    should define_enum_for(:highest_degree).with_values({ b_tech: 0, mca: 1, mba: 2, msc: 3, bca: 4, be: 5, other: 6 })
  end

  it { should delegate_method(:name).to(:profession).with_prefix("profession").allow_nil }

  describe "set constants" do
    before { stub_const("#{described_class}", professional_detail) }
    it { expect(described_class::REQUIRED_FIELD).to eq([:highest_degree, :profession_id]) }
    it { expect(described_class::NON_PROFESSIONAL_REQUIRED_FIELD).to eq([:highest_degree, :profession_id]) }
  end
end