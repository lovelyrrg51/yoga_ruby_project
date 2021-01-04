require 'rails_helper'

RSpec.describe ShivyogChangeLog, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:change_loggable) }
    it { should belong_to(:creator).class_name('User').with_foreign_key(:whodunnit) }
  end

  describe "validations" do
    it { should validate_presence_of(:description) }
  end
end