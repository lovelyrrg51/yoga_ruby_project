require 'rails_helper'

RSpec.describe SadhakProfileAttendedShivir, type: :model do

  it { is_expected.to act_as_paranoid }
  it { should belong_to(:sadhak_profile) }
end