require 'rails_helper'

RSpec.describe MergeSadhak, type: :model do
  describe "associations" do
    it { should belong_to(:primary_sadhak).class_name('SadhakProfile').with_foreign_key('primary_sadhak_id')}
    it { should belong_to(:secondary_sadhak).class_name('SadhakProfile').with_foreign_key('secondary_sadhak_id')}
    it { should belong_to(:user)}
    it { should have_one(:sadhak_profile).through(:user)}
  end

  describe 'delegate methods' do
    it { should delegate_method(:syid).to(:sadhak_profile).allow_nil }
    it { should delegate_method(:full_name).to(:sadhak_profile).allow_nil }
  end

  it { should serialize(:meta_data) }
end
