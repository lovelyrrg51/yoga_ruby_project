require 'rails_helper'

RSpec.describe DsProductInventoryRequest, type: :model do

  describe "associations" do

    it { should belong_to(:ds_shop) }
    it { should have_many(:ds_inventory_requests)}
  end

  it { should validate_presence_of(:ds_shop_id) }

  it do
    should define_enum_for(:status).
      with_values([:requested, :delivered, :received, :closed])
  end

end
