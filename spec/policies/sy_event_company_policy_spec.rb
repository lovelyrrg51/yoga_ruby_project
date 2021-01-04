RSpec.describe SyEventCompanyPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :show? do
    it 'always grants access' do
      expect(subject).to permit(User.new, nil)
    end
  end
end
