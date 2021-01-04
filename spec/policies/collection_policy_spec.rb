RSpec.describe CollectionPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :create?, :edit?, :update?, :destroy?, :create_episodes_collection? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super_admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :shivir_episode_upload_access? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is not super_admin but has shivir episode upload access' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, sadhak_profile: sadhak_profile
      allow(sadhak_profile).to receive(:has_shivir_episode_upload_access?).and_return true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super_admin and does not have shivir episode upload access' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, sadhak_profile: sadhak_profile
      allow(sadhak_profile).to receive(:has_shivir_episode_upload_access?).and_return false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :is_shivir_episode_access_admin? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is not super_admin but is shivir episode access admin' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, sadhak_profile: sadhak_profile
      allow(sadhak_profile).to receive(:is_shivir_episode_access_admin?).and_return true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super_admin and is not shivir episode access admin' do
      sadhak_profile = SadhakProfile.new
      user = User.new super_admin: false, sadhak_profile: sadhak_profile
      allow(sadhak_profile).to receive(:is_shivir_episode_access_admin?).and_return false
      expect(subject).not_to permit(user, nil)
    end
  end
end
