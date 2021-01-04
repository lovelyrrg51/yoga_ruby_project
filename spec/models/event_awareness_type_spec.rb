require 'rails_helper'

RSpec.describe EventAwarenessType, type: :model do

  it { should have_many(:event_awarenesses)}

end
