RSpec.describe SpiritualJourneyPolicy, type: :policy do
  subject { described_class }

  permissions :show?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/digital_store admin' do
      user = User.new super_admin: false, digital_store_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :create?, :update? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user sadhak profile is same as spiritual_practice sadhak profile' do
      user = User.new super_admin: false, digital_store_admin: false
      sadhak_profile = SadhakProfile.new
      user = User.new sadhak_profile: sadhak_profile
      spiritual_practice = SpiritualPractice.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, spiritual_practice)
    end

    it 'grants access if user sadhak profiles include spiritual_practice sadhak profile' do
      user = User.new super_admin: false, digital_store_admin: false
      sadhak_profile = SadhakProfile.new
      user = User.new sadhak_profiles: [sadhak_profile]
      spiritual_practice = SpiritualPractice.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, spiritual_practice)
    end

    it 'denies access if user is not super/digital_store admin or user sadhak profile is different from spiritual_practice sadhak profile' do
      user = User.new super_admin: false, digital_store_admin: false
      user = User.new sadhak_profile: SadhakProfile.new
      spiritual_practice = SpiritualPractice.new sadhak_profile: SadhakProfile.new
      expect(subject).not_to permit(user, spiritual_practice)
    end
  end
end
