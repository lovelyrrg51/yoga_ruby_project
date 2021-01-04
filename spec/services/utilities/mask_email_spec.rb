RSpec.describe Utilities::MaskEmail do
  subject { described_class.call email }

  describe '.call' do
    context 'when email is present' do
      let(:email) { 'test@example.com' }
      it { is_expected.to eq 't**t@example.com' }
    end

    context 'when email is blank' do
      let(:email) { nil }
      it { is_expected.to eq '' }
    end
  end
end
