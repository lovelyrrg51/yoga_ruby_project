RSpec.describe GetSenderEmail, type: :service do
  subject { described_class.call object }

  context 'when object is an event in India' do
    let(:object) { Event.new address: Address.new(country_id: 113) }
    it { is_expected.to eq 'registration@shivyogindia.com' }
  end

  context 'when object is an event outside of India' do
    let(:object) { Event.new address: Address.new(country_id: 114) }
    it { is_expected.to eq 'support@absclp.com' }
  end

  context 'when object is not SyClub/SadhakProfile/Event' do
    let(:object) { User.new }
    it { is_expected.to eq 'support@absclp.com' }
  end
end
