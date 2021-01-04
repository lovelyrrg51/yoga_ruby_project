RSpec.describe DbCountryPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :new?, :create?, :edit?, :update?, :destroy?, :country_index_for_state?, :country_index_for_state_city? do
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

  permissions :show? do
    it 'always grants access' do
      expect(subject).to permit(User.new, nil)
    end
  end
end
