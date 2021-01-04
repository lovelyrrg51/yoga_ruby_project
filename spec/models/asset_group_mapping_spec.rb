require 'rails_helper'
RSpec.describe AssetGroupMapping, type: :model do
  describe "associations" do
    it { should belong_to :digital_asset }
    it { should belong_to :user_group }
  end
end
