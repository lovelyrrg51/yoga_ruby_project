RSpec.describe PaymentReconcilationPolicy, type: :policy do
  subject { described_class }

  permissions :index?, :create?, :update?, :reconcilation?, :generate_reconcilation_file? do
    it 'grants access if user is super_admin' do
      user = User.new super_admin: true, india_admin: false
      expect(subject).to permit(user, nil)
    end

    it 'grants access if user is india_admin' do
      user = User.new super_admin: false, india_admin: true
      expect(subject).to permit(user, nil)
    end

    it 'denies access if user is not super/india admin' do
      user = User.new super_admin: false, india_admin: false
      expect(subject).not_to permit(user, nil)
    end
  end
end
