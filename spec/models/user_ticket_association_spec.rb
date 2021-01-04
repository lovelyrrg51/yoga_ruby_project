UserTicketAssociation
require 'rails_helper'

RSpec.describe UserTicketAssociation, type: :model do

  describe "associations" do

    it { should belong_to(:user) }
    it { should belong_to(:ticket)}
  end


end
