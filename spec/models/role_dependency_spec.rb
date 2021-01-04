require 'rails_helper'

RSpec.describe RoleDependency, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:role_dependable) }
      it { should belong_to(:user_role) }
      it { should belong_to(:last_updated_by).class_name('User').with_foreign_key(:whodunnit) }
    end

    context 'for has one' do
      it { should have_one(:user).through(:user_role) }
      it { should have_one(:role).through(:user_role) }
      it { should have_one(:sadhak_profile).through(:user) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:user_role_id) }
    it { should validate_uniqueness_of(:user_role_id).scoped_to(:role_dependable_type, :role_dependable_id) }
  end

  describe "delegate" do
    it { should delegate_method(:syid).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:first_name).to(:sadhak_profile).allow_nil }
  end
end