require 'rails_helper'

RSpec.describe DsInventoryRequest, type: :model do

  describe "associations" do
    it { should belong_to(:ds_product) }
    it { should belong_to(:ds_product_inventory_request) }
  end

  it { should validate_presence_of(:ds_product_inventory_request_id) }

end
