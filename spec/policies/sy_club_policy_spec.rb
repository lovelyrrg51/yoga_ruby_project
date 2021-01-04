RSpec.describe SyClubPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :create?, :new?, :show? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user permissions include :country_admin' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: true } }
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is country admin' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: false } }
      allow(user).to receive(:is_country_admin?) { true }
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/club/country admin' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: false } }
      allow(user).to receive(:is_country_admin?) { false }
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :update? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user permissions include :country_admin' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: true } }
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user created the forum' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: false } }
      sy_club = SyClub.new user: user
      expect(subject).to permit(user, sy_club)
    end

    it 'denies access if user is not super/club admin' do
      user = User.new super_admin: false, club_admin: false
      allow(user).to receive(:permissions).with(nil) { { country_admin: false } }
      expect(subject).not_to permit(user, SyClub.new)
    end
  end

  permissions :admin_transfer? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin and forum is in India' do
      user = User.new india_admin: true
      sy_club = SyClub.new address: Address.new(country_id: 113)
      expect(subject).to permit(user, sy_club)
    end

    it 'denies access if user is not super/club admin' do
      user = User.new super_admin: false, club_admin: false, india_admin: false
      sy_club = SyClub.new address: Address.new(country_id: 113)
      expect(subject).not_to permit(user, sy_club)
    end
  end

  permissions :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/club admin' do
      user = User.new super_admin: false, club_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :forum_admin?, :offline_forum_data_migration? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
