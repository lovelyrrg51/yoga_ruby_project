require 'rails_helper'

RSpec.describe SyClubEventAssociation, type: :model do

  describe "associations" do
    it { should belong_to(:event) }
    it { should belong_to(:sy_club) }
  end
end