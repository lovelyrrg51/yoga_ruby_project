RSpec.describe AddressProofTypePolicy, type: :policy do
  subject { described_class }

  permissions :index?, :new?, :create?, :edit?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, photo_approval_admin: false, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is photo_approval admin' do
      user = User.new super_admin: false, photo_approval_admin: true, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india admin' do
      user = User.new super_admin: false, photo_approval_admin: false, india_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/photo_approval/india admin' do
      user = User.new super_admin: false, photo_approval_admin: false, india_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
