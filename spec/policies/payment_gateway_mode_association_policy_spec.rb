RSpec.describe PaymentGatewayModeAssociationPolicy, type: :policy do
  subject { described_class }

  permissions :new?, :create?, :show?, :edit?, :update?, :destroy? do
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
