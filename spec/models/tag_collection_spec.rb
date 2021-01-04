require 'rails_helper'

RSpec.describe TagCollection, type: :model do

  describe "associations" do
    it { should have_many(:asset_tags)}
  end


end
