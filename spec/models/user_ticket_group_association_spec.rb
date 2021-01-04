require 'rails_helper'

RSpec.describe UserTicketGroupAssociation, type: :model do

  describe "associations" do

    it { should belong_to(:ticket_group) }
    it { should belong_to(:user)}
  end

end
