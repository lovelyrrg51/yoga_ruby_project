RSpec.describe SyClubUserRolePolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update?, :destroy? do
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
