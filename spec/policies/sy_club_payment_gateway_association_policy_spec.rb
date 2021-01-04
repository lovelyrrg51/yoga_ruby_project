RSpec.describe SyClubPaymentGatewayAssociationPolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update?, :destroy? do
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
end
