require 'rails_helper'

RSpec.describe TicketType, type: :model do

  describe "associations" do

    it { should belong_to(:ticket_group) }
    it { should have_many(:tickets)}
  end

  describe "validations" do

    it { should validate_presence_of(:ticket_type) }
    it { should validate_uniqueness_of(:ticket_type).case_insensitive }
    it { should validate_length_of(:ticket_type).is_at_most(255)}
    it { should validate_presence_of(:ticket_group_id) }
    it { should validate_numericality_of(:ticket_group_id) }

  end

  it { should delegate_method(:name).to(:ticket_group).with_prefix}


end
