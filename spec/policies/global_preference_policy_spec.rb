RSpec.describe GlobalPreferencePolicy, type: :policy do
  subject { described_class }

  permissions :index?, :create?, :edit? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super admin' do
      user = User.new super_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :update?, :destroy? do
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
end
