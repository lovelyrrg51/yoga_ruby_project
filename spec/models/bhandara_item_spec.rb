require 'rails_helper'
RSpec.describe BhandaraItem, type: :model do
  it { should belong_to :bhandara_detail }
  it { should validate_uniqueness_of :day }
  # it do
  #   is_expected.to validate_uniqueness_of(:bhandara_detail_id)
  # end
end
