RSpec.describe CreateSadhakProfile, type: :service do
  shared_examples 'success' do
    its(:success) { is_expected.to be true }
    its(:sadhak_profile) { is_expected.to be_persisted }

    it { expect {subject}.to change { SadhakProfile.count}.by 1 }
    it { expect {subject}.to change { Address.count}.by 1 }
    it { expect {subject}.to change { Relation.count}.by 1 }
    it { expect {subject}.to change { User.count}.by 1 }
  end

  shared_examples 'failure' do
    its(:success) { is_expected.to be false }
    its(:sadhak_profile) { is_expected.not_to be_persisted }
    its(:error) { is_expected.to be_present }
  end

  describe '.call' do
    let!(:user) { create :user, email: 'test@example.com' }
    let(:address_params) { {} }

    subject do
      described_class.call(
        sadhak_profile_params: sadhak_profile_params,
        address_params: address_params,
        user: user
      )
    end

    context 'when sadhak_profiles_params is valid and has only email' do
      let(:sadhak_profile_params) do
        {
          first_name: 'John',
          last_name: 'Doe',
          email: 'john.doe@example.com'
        }
      end

      it_behaves_like 'success'
    end

    context 'when sadhak_profiles_params is valid and has only mobile' do
      let(:sadhak_profile_params) do
        {
          first_name: 'John',
          last_name: 'Doe',
          mobile: '+91 9945 731 953'
        }
      end

      it_behaves_like 'success'
    end

    context 'when phone number is invalid' do
      let(:sadhak_profile_params) do
        {
          first_name: 'John',
          last_name: 'Doe',
          mobile: '0123456789'
        }
      end

      it_behaves_like 'failure'
      its('error.message') { is_expected.to eq 'Validation failed: Mobile is invalid' }
    end

  end
end
