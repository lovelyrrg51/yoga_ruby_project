RSpec.describe Utilities::UniqueKeyGenerator do
  subject { described_class.generate }

  describe '.generate' do
    its(:length) { is_expected.to eq 8 }
    it { is_expected.to be_a String }
  end
end
