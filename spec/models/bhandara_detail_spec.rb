require 'rails_helper'

RSpec.describe BhandaraDetail, type: :model do
  
  describe "validations" do
    it { should validate_presence_of(:budget) }
    it { should validate_presence_of(:event_id) }
    it { should validate_numericality_of(:budget) }
    it { should allow_value('123.456').for(:budget) }
  end

  describe "associations" do
    it { should belong_to :event }
    it { should have_many(:bhandara_items)}
  end
end
