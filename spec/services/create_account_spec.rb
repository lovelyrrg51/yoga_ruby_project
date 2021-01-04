RSpec.describe CreateAccount, type: :service do
  subject(:sadhak_profile) { described_class.call sign_up_params }

  context 'with valid params, email only' do
    let(:sign_up_params) do
      {
        first_name: 'John',
        email: 'john@example.com',
        mobile: nil,
        password: '12345678'
      }
    end

    it { is_expected.to be_persisted }
    it { expect { subject }.to change { SadhakProfile.count}.by 1 }
    it { expect { subject }.to change { User.count}.by 1 }
  end

  context 'with valid params, mobile only' do
    let(:sign_up_params) do
      {
        first_name: 'John',
        email: nil,
        mobile: '9945731953',
        password: '12345678'
      }
    end

    it { is_expected.to be_persisted }
    it { expect { subject }.to change { SadhakProfile.count}.by 1 }
    it { expect { subject }.to change { User.count}.by 1 }
  end

  context 'when sadhak profile with email already exists' do
    let(:sign_up_params) do
      {
        first_name: 'John',
        email: 'john@example.com',
        mobile: nil,
        password: '12345678'
      }
    end

    before do
      create :sadhak_profile, first_name: 'John', email: 'john@example.com',
        user: create(:user)
    end

    it { is_expected.not_to be_persisted }
    its('errors.full_messages') { is_expected.to include 'Email has already been taken' }
  end

  context 'when sadhak profile with email already exists' do
    let(:sign_up_params) do
      {
        first_name: 'John',
        email: nil,
        mobile: '9945731953',
        password: '12345678'
      }
    end

    before do
      create :sadhak_profile, first_name: 'John', mobile: '+919945731953',
        user: create(:user)
    end

    it { is_expected.not_to be_persisted }
    its('errors.full_messages') { is_expected.to include 'Mobile has already been taken' }
  end
end
