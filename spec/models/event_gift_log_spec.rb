require 'rails_helper'

RSpec.describe EventGiftLog, type: :model do
  describe "associations" do
    it { should belong_to(:event)}
    it { should have_many(:attachments)}
  end

  describe "validations" do
    it { should validate_presence_of(:event_id) }
    it { should validate_uniqueness_of(:event_id) }
  end

  it do
    should define_enum_for(:status).
      with_values([:initiated, :processing, :done, :failed])
  end
end
