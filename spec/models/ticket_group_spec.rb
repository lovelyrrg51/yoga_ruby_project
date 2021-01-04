require 'rails_helper'

RSpec.describe TicketGroup, type: :model do

  describe "associations" do

    it { should have_many(:user_ticket_group_associations)}
    it { should have_many(:users).through(:user_ticket_group_associations) }
    it { should have_many(:ticket_types)}
    it { should have_many(:tickets).through(:ticket_types)}
  end

  describe "validations" do

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(255)}

  end
  
end
