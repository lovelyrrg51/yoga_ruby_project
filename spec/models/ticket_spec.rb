require 'rails_helper'

RSpec.describe Ticket, type: :model do

  describe "associations" do

    it { should belong_to(:ticketable) }
    it { should belong_to(:user)}
    it { should have_many(:ticket_responses)}
  end

  describe "validations" do

    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255)}

  end

  it do
    should define_enum_for(:priority).
      with_values({low: 1, medium: 2, high: 3})
  end

end
