RSpec.describe UpdateSadhakProfile, type: :service do
  let!(:sadhak_profile) do
    CreateAccount.call(
      first_name: 'John',
      mobile: '+91-9945731953',
      email: 'john@example.com',
      password: '12345678'
    )
  end

  describe '.call' do
    subject do
      described_class.call(
        sadhak_profile: sadhak_profile,
        sadhak_profile_params: sadhak_profile_params,
        address_params: address_params
      )
    end

    context 'change email' do
      let(:sadhak_profile_params) { { email: 'jane@exmaple.com' } }
      let(:address_params) { {} }

      its(:success) { should be true }
      its(:email_verification_needed) { should be true }
      its(:mobile_verification_needed) { should be false }
      its('sadhak_profile.email') { should eq 'jane@exmaple.com' }
      its('sadhak_profile.user.email') { should eq 'jane@exmaple.com' }
    end

    context 'change phone number' do
      let(:sadhak_profile_params) { { mobile: '91 9945731954' } }
      let(:address_params) { {} }

      its(:success) { should be true }
      its(:email_verification_needed) { should be false }
      its(:mobile_verification_needed) { should be true }
      its('sadhak_profile.mobile') { should eq '+919945731954' }
      its('sadhak_profile.user.contact_number') { should eq '+919945731954' }
    end

    context 'change address' do
      let!(:country) { create :db_country }
      let!(:state) { create :db_state, country: country}
      let(:address_params) do
        {
          country_id: country.id,
          state_id: state.id
        }
      end
      let(:sadhak_profile_params) { {} }

      its(:success) { should be true }
      its(:email_verification_needed) { should be false }
      its(:mobile_verification_needed) { should be false }
      its('sadhak_profile.address.country_id') { should eq country.id }
      its('sadhak_profile.address.state_id') { should eq state.id }
    end
  end

end
