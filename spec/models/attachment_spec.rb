require 'rails_helper'
RSpec.describe Attachment, type: :model do
  it { is_expected.to act_as_paranoid }
  it { should belong_to :attachable }

  describe "validations" do
    it { should validate_presence_of(:attachable_type).on(:update) }
    it { should validate_presence_of(:attachable_id).on(:update) }
  end
end
