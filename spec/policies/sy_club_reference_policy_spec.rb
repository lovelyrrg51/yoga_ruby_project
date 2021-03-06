RSpec.describe SyClubReferencePolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      record = SyClubReference.new sy_club: SyClub.new
      expect(subject).to permit(user, record)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      record = SyClubReference.new sy_club: SyClub.new
      expect(subject).to permit(user, record)
    end

    it 'grants access if user has permission :country_admin' do
      user = User.new super_admin: false, club_admin: false
      record = SyClubReference.new sy_club: SyClub.new
      allow(user).to receive(:permissions).with(record) { { country_admin: true } }
      expect(subject).to permit(user, record)
    end

    it 'grants access if user created sy_club_reference forum' do
      user = User.new super_admin: false, club_admin: false
      record = SyClubReference.new sy_club: SyClub.new(user: user)
      allow(user).to receive(:permissions).with(record) { { country_admin: false } }
      expect(subject).to permit(user, record)
    end

    it 'denies access if user is not super/club/country admin and is not related to forum' do
      user = User.new super_admin: false
      record = SyClubReference.new sy_club: SyClub.new
      allow(user).to receive(:permissions).with(record) { { country_admin: false } }
      expect(subject).not_to permit(user, record)
    end
  end

  permissions :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, club_admin: false
      record = SyClubReference.new sy_club: SyClub.new
      expect(subject).to permit(user, record)
    end

    it 'grants access if user is club_admin' do
      user = User.new super_admin: false, club_admin: true
      record = SyClubReference.new sy_club: SyClub.new
      expect(subject).to permit(user, record)
    end

    it 'denies access if user is not super/club admin' do
      user = User.new super_admin: false, club_admin: false
      record = SyClubReference.new sy_club: SyClub.new
      expect(subject).not_to permit(user, record)
    end
  end
end
