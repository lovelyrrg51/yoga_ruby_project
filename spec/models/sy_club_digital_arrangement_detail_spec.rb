require 'rails_helper'

RSpec.describe SyClubDigitalArrangementDetail, type: :model do

  it { should belong_to(:sy_club) }

  it { should validate_numericality_of(:lcd_size).is_greater_than_or_equal_to(42).only_integer.allow_nil }
    
end