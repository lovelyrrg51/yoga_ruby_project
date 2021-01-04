RSpec.describe CcavenueConfigPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, event_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is event admin' do
      user = User.new super_admin: false, event_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/event admin' do
      user = User.new super_admin: false, event_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :payment_modes? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super_admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
