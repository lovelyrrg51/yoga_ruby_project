require 'rails_helper'

RSpec.describe DigitalAssetSecret, type: :model do
  it { is_expected.to act_as_paranoid }

  it { should have_one(:digital_asset) }

  describe "validations" do
    it { should validate_presence_of(:asset_dl_url) }
    it { should validate_presence_of(:asset_file_name) }
    it { should validate_presence_of(:asset_url) }
    it { should validate_uniqueness_of(:video_id) }
    it { should validate_numericality_of(:asset_file_size).is_greater_than(0) }
  end
end
