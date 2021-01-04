require 'rails_helper'

RSpec.describe FrequentSadhnaType, type: :model do
  it { should have_many(:spiritual_practice_frequent_sadhna_type_associations).dependent(:destroy)}
  it { should have_many(:spiritual_practices).through(:spiritual_practice_frequent_sadhna_type_associations)}

  it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }

  describe '.sadhna_name' do
    let!(:record_1) { create :frequent_sadhna_type, name: 'example' }
    let!(:record_2) { create :frequent_sadhna_type, name: 'test' }

    subject { described_class.sadhna_name('test') }

    its(:size) { should be 1 }
    it { is_expected.not_to include record_1 }
    it { is_expected.to include record_2 }
  end
end
