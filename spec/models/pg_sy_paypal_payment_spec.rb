require 'rails_helper'

RSpec.describe PgSyPaypalPayment, type: :model do

  describe "associations" do
    it { should belong_to(:event_order)}
    it { should belong_to(:sy_club)}
  end

  it do
    should define_enum_for(:status).with_values({pending: 0, success: 1, failure: 2})
  end
end
