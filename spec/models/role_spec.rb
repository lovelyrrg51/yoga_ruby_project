require 'rails_helper'

RSpec.describe Role, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should have_many(:user_roles) }
    it { should have_many(:users).through(:user_roles) }
    it { should belong_to(:last_updated_by).class_name('User').with_foreign_key(:whodunnit) }
  end

  describe "validations" do
    subject {FactoryBot.build(:role)}

    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_most(140) }
    it { should validate_uniqueness_of(:name).ignoring_case_sensitivity }

    it { should validate_presence_of(:description) }
    it { should validate_length_of(:description).is_at_most(250) }

    it { should validate_presence_of(:role_type) }
  end

  it do
    should define_enum_for(:role_type).with_values({independent: 0, dependent: 1})
  end

  describe 'aasm states' do
    it { should have_state(:independent) }
  end
end