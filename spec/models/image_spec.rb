require 'rails_helper'

RSpec.describe Image, type: :model do

  it { is_expected.to act_as_paranoid }
  
  describe "associations" do
    it { should belong_to(:imageable)}
    it { should belong_to(:advance_profile).class_name('AdvanceProfile').with_foreign_key('imageable_id')}
  end

end
