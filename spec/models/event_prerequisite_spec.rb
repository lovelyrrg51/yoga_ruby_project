require 'rails_helper'

RSpec.describe EventPrerequisite, type: :model do
  describe "associations" do
    it { should belong_to(:cannonical_event)}
    it { should belong_to(:prerequisite_cannonical_event).with_foreign_key(:prerequisite_cannonical_event_id).class_name('CannonicalEvent')}
  end
end
