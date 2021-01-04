RSpec.describe OmniauthService, type: :service do

  describe '.from_google' do
    let(:auth) do
      OmniAuth::AuthHash.new({
        "provider" => "google_oauth2",
        "uid" => "0123456789876543210",
        "info" => {
          "name" => "John Doe",
          "email" => "johndoe@example.com",
          "email_verified" => true,
          "first_name" => "John",
          "last_name" => "Doe",
          "image" => nil
        }
      })
    end

    subject(:user) { described_class.from_google auth }

    context 'when user with auth provider & uid exist' do
      let!(:existing_user) do
        create :user, oauth_provider: auth.provider, oauth_uid: auth.uid
      end

      it 'returns existing user' do
        is_expected.to eq existing_user
      end
    end

    context 'when user with auth provider & uid does not exist but user with same email exist' do
      let!(:existing_user) do
        create :user, email: auth.info.email, oauth_image: 'test'
      end

      it 'returns existing user' do
        is_expected.to eq existing_user
      end

      context 'updates existing user with oauth info' do
        its(:oauth_provider) { should eq auth.provider }
        its(:oauth_uid) { should eq auth.uid }
        its(:oauth_image) { should eq auth.info.image }
        its(:name) { should eq auth.info.first_name }
        its(:last_name) { should eq auth.info.last_name }
        its(:is_email_verified) { should eq auth.info.email_verified }
      end

      context 'user has no associated sadhak profile' do
        it 'creates new sadhak profile' do
          expect { subject }.to change { SadhakProfile.count }.by 1
        end
      end
    end

    context 'no users with oauth info found' do
      it 'creates new user' do
        expect { subject }.to change { User.count }.by 1
      end

      it 'creates new sadhak profile' do
        expect { subject }.to change { SadhakProfile.count }.by 1
      end

      context 'new user' do
        its(:oauth_provider) { should eq auth.provider }
        its(:oauth_uid) { should eq auth.uid }
        its(:oauth_image) { should eq auth.info.image }
        its(:name) { should eq auth.info.first_name }
        its(:last_name) { should eq auth.info.last_name }
        its(:email) { should eq auth.info.email }
        its(:is_email_verified) { should eq auth.info.email_verified }
      end

      context 'new sadhak profile' do
        subject { user.sadhak_profile }

        its(:first_name) { should eq auth.info.first_name }
        its(:last_name) { should eq auth.info.last_name }
        its(:email) { should eq auth.info.email }
        its(:is_email_verified) { should eq auth.info.email_verified }
      end
    end

  end

end
