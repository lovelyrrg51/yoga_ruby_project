require 'rails_helper'

RSpec.describe UserGroup, type: :model do

  describe "associations" do
    it { should have_many(:user_group_mappings)}
    it { should have_many(:asset_group_mappings)}
    it { should have_many(:users).through(:user_group_mappings)}
    it { should have_many(:digital_assets).through(:asset_group_mappings)}
  end
  
end
