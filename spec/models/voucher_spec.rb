require 'rails_helper'

RSpec.describe Voucher, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do

    it { should belong_to(:receiptable) }
    it { should have_many(:attachments)}
    it { should have_one(:attachment).order('id DESC') }
  end

  describe "validations" do

    it { should validate_presence_of(:voucher_number) }
    it { should validate_presence_of(:receiptable) }
    it { should validate_presence_of(:voucher_type) }

  end

  it do
    should define_enum_for(:voucher_type).
      with_values([:receipt, :invoice, :refund])
  end

  describe 'aasm states' do
    it { should have_state(:receipt) }
  end

end
