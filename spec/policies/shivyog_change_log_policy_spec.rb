RSpec.describe ShivyogChangeLogPolicy, type: :policy do
  subject { described_class }

  permissions :create?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false, event_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true, event_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is event_admin' do
      user = User.new super_admin: false, india_admin: false, event_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india/event admin' do
      user = User.new super_admin: false, india_admin: false, event_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
