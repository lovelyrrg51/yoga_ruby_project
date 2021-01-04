RSpec.describe OtherSpiritualAssociationPolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user and other_spiritual_association has same sadhak profile' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, digital_store_admin: false,
        sadhak_profile: sadhak_profile
      record = OtherSpiritualAssociation.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, record)
    end

    it 'grants access if user sadhak profiles include other_spiritual_association sadhak profile' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, digital_store_admin: false,
        sadhak_profiles: [sadhak_profile]
      record = OtherSpiritualAssociation.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, record)
    end

    it 'denies access if user is not super/digital_store admin and does not share the same sadhak profile' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, digital_store_admin: false,
        sadhak_profiles: [SadhakProfile.new]
      record = OtherSpiritualAssociation.new sadhak_profile: SadhakProfile.new
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :show?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
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
end
