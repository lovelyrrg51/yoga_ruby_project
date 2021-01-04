RSpec.describe UserGroupPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :create?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is group_admin' do
      user = User.new super_admin: false, digital_store_admin: false, group_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/digital_store/group admin' do
      user = User.new super_admin: false, digital_store_admin: false, group_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end

  permissions :show? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, digital_store_admin: false, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is digital_store_admin' do
      user = User.new super_admin: false, digital_store_admin: true, group_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is group_admin' do
      user = User.new super_admin: false, digital_store_admin: false, group_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is not super/digital_store/group admin and user is in user_group' do
      user = User.new super_admin: false, digital_store_admin: false, group_admin: false
      user_group = user.user_groups.new
      expect(subject).to permit(user, user_group)
    end

    it 'denies access if user is not super/digital_store/group admin and user is not in user_group' do
      user = User.new super_admin: false, digital_store_admin: false, group_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
