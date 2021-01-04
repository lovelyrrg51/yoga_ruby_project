require 'rails_helper'

RSpec.describe EventSeatingCategoryAssociation, type: :model do

  describe "associations" do

    it { should belong_to(:event) }
    it { should belong_to(:seating_category) }
    it { should have_many(:event_order_line_items)}
    it { should have_many(:valid_event_registrations).conditions(event_registrations: {status: EventRegistration.valid_registration_statuses}).class_name('EventRegistration')}
  end

  describe "validations" do

    it { should validate_presence_of(:event) }
    it { should validate_presence_of(:seating_category) }
    it { should validate_presence_of(:price) }
    it { should validate_numericality_of(:price) }
    # it { should validate_uniqueness_of(:seating_category).scoped_to(:event).conditions(event_seating_category_association: {is_deleted: false}) }
  end

  describe 'delegate methods' do
    it { should delegate_method(:category_name).to(:seating_category).allow_nil }
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end

end
