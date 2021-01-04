RSpec.describe FindSadhakProfile, type: :service do
  describe '.by_query' do
    subject { described_class.by_query query }

    let!(:sadhak_profile) do
      create :sadhak_profile, email: 'john@example.com', mobile: '+919945731953',
        user: create(:user)
    end

    context 'query is blank' do
      let(:query) { '  ' }
      it { is_expected.to be nil }
    end

    context 'query is SYID' do
      let(:query) { sadhak_profile.syid.downcase }
      it { is_expected.to eq sadhak_profile }
    end

    context 'query is email' do
      let(:query) { 'john@example.com  ' }
      it { is_expected.to eq sadhak_profile }
    end

    context 'query is phone number' do
      let(:query) { '91 9945 731 953' }
      it { is_expected.to eq sadhak_profile }
    end

    context 'invalid query' do
      let(:query) { 'abc 123' }
      it { is_expected.to be nil }
    end
  end

  describe '.by_query_and_first_name' do
    subject { described_class.by_query_and_first_name query, first_name }

    let!(:sadhak_profile) do
      create :sadhak_profile, email: 'john@example.com', mobile: '+919945731953',
        user: create(:user), first_name: 'John'
    end

    context 'no sadhak profiles found with query' do
      let(:query) { 'john123@example.com' }
      let(:first_name) { 'John' }

      it { is_expected.to be nil }
    end

    context 'sadhak profile found but first name does not match' do
      let(:query) { 'john@example.com' }
      let(:first_name) { 'jane' }

      it { is_expected.to be nil }
    end

    context 'sadhak profile found and first name matches' do
      let(:query) { 'john@example.com' }
      let(:first_name) { 'john' }

      it { is_expected.to eq sadhak_profile }
    end
  end
end
