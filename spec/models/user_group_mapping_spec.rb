require 'rails_helper'

RSpec.describe UserGroupMapping, type: :model do

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:user_group)}
  end


end
