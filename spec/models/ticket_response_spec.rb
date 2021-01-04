require 'rails_helper'

RSpec.describe TicketResponse, type: :model do

  describe "associations" do

    it { should belong_to(:ticket) }
    it { should belong_to(:user)}
    it { should have_one(:attachment)}
  end

  it do
    should define_enum_for(:status).
      with_values({ waiting_for_response: 1, waiting_for_none: 0})
  end

end
