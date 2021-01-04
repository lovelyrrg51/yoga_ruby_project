RSpec.describe AdvanceProfilePolicy, type: :policy do
  subject { described_class }

  permissions :show?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store admin' do
      user = User.new super_admin: false, digital_store_admin: true, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india admin' do
      user = User.new super_admin: false, digital_store_admin: false, india_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/digital_store/india admin' do
      user = User.new super_admin: false, digital_store_admin: false, india_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :create? do
    it 'always grants access' do
      expect(subject).to permit(User.new, nil)
    end
  end

  permissions :update? do
    it 'grants access if user could view the record' do
      allow_any_instance_of(described_class).to receive(:show?).and_return true
      expect(subject).to permit(User.new, nil)
    end

    it 'grants access if user and advance profile have same sadhak profile' do
      allow_any_instance_of(described_class).to receive(:show?).and_return false
      sadhak_profile = SadhakProfile.new
      user = User.new sadhak_profile: sadhak_profile
      advance_profile = AdvanceProfile.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, advance_profile)
    end

    it 'grants access if user sadhak profiles contain advance profile\'s sadhak profile' do
      allow_any_instance_of(described_class).to receive(:show?).and_return false
      sadhak_profile = SadhakProfile.new
      user = User.new sadhak_profiles: [sadhak_profile]
      advance_profile = AdvanceProfile.new sadhak_profile: sadhak_profile
      expect(subject).to permit(user, advance_profile)
    end

    it 'denies access if user could not view the record or not share sadhak profile with advance profile' do
      allow_any_instance_of(described_class).to receive(:show?).and_return false
      advance_profile = AdvanceProfile.new sadhak_profile: SadhakProfile.new
      expect(subject).not_to permit(User.new, advance_profile)
    end
  end
end
