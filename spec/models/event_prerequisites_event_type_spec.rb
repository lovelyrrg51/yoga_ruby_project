require 'rails_helper'

RSpec.describe EventPrerequisitesEventType, type: :model do
  describe "associations" do
    it { should belong_to(:event).inverse_of(:event_prerequisites_event_types)}
    it { should belong_to(:event_type)}
  end
end
