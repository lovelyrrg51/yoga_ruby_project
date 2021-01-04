RSpec.describe ActivityEventTypePricingAssociationPolicy do
  subject { described_class }

  permissions :create?, :update?, :destroy? do
    it 'grants access if user is super_admin' do
      expect(subject).to permit(User.new(super_admin: true, event_admin: false), nil)
    end

    it 'grants access if user is event_admin' do
      expect(subject).to permit(User.new(super_admin: false, event_admin: true), nil)
    end

    it 'denies access if user is not super_admin or event_admin' do
      expect(subject).not_to permit(User.new(super_admin: false, event_admin: false), nil)
    end
  end
end
