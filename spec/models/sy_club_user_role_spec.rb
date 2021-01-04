require 'rails_helper'

RSpec.describe SyClubUserRole, type: :model do

  describe "validations" do
    it { should validate_presence_of(:role_name) }
    it { should validate_length_of(:role_name).is_at_least(3) }
  end

end