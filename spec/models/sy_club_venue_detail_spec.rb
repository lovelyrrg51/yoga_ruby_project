require 'rails_helper'

RSpec.describe SyClubVenueDetail, type: :model do

  it { should belong_to(:sy_club) }

end