require 'rails_helper'

RSpec.describe UserRole, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:role)}
    it { should belong_to(:last_updated_by).class_name('User').with_foreign_key(:whodunnit)}
    it { should have_many(:role_dependencies).dependent(:destroy)}
  end
end
