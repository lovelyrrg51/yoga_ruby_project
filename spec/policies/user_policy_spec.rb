RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :show? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false,
        digital_store_admin: false, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true,
        digital_store_admin: false, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, india_admin: false,
        digital_store_admin: true, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is group_admin' do
      user = User.new super_admin: false, india_admin: false,
        digital_store_admin: false, group_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india/digital_store/group admin' do
      user = User.new super_admin: false, india_admin: false,
        digital_store_admin: false, group_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :create?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false, digital_store_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true, digital_store_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, india_admin: false, digital_store_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india/digital_store admin' do
      user = User.new super_admin: false, india_admin: false, digital_store_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :reset_sadhak_password? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is country_admin' do
      user = User.new super_admin: false, india_admin: false
      allow(user).to receive(:is_country_admin?).and_return true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india/country admin' do
      user = User.new super_admin: false, india_admin: false
      allow(user).to receive(:is_country_admin?).and_return false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :wp_reset_password? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false, event_admin: false, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true, event_admin: false, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is event_admin' do
      user = User.new super_admin: false, india_admin: false, event_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, india_admin: false, event_admin: false, club_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india/event/club admin' do
      user = User.new super_admin: false, india_admin: false, event_admin: false, club_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :edit?, :update_password? do
    it 'grants access if user is present' do
      expect(subject).to permit(User.new, nil)
    end

    it 'denies access if user is not present' do
      expect(subject).not_to permit(nil, nil)
    end
  end
end
