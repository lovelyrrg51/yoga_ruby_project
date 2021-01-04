require 'rails_helper'

RSpec.describe PandalDetail, type: :model do
  
  it { should belong_to(:event)}

  it do
    should define_enum_for(:seating_type).with_values({both: 0, matresses: 1, chairs: 2})
  end

  describe "validations" do
    it { should validate_presence_of(:len) }
    it { should validate_presence_of(:width) }
    it { should validate_presence_of(:seating_type) }
    it { should validate_presence_of(:arrangement_details) }
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:chairs_count) }
    # it { should validate_uniqueness_of(:event_id) }
    it { should validate_numericality_of(:matresses_count) }
    it { should validate_numericality_of(:chairs_count) }
    it { should validate_numericality_of(:len) }
    it { should validate_numericality_of(:width) }
  end

end
