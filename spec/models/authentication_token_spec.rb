require 'rails_helper'
RSpec.describe AuthenticationToken, type: :model do
  it { is_expected.to act_as_paranoid }
  it { should belong_to :user }
end
