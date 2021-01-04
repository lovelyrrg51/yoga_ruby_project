require 'rails_helper'

RSpec.describe DsProductDetail, type: :model do

  describe "associations" do
    it { should belong_to(:ds_product) }
  end
end
