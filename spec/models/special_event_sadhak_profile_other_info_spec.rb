require 'rails_helper'

RSpec.describe SpecialEventSadhakProfileOtherInfo, type: :model do

  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:event_order_line_item) }
    it { should belong_to(:event) }
    it { should have_many(:special_event_sadhak_profile_references) }
    it { should have_many(:sadhak_profiles).through(:special_event_sadhak_profile_references).source(:sadhak_profile) }
  end

  describe "validations" do
    it { should validate_presence_of(:sadhak_profile_id) }
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:father_name) }
    it { should validate_presence_of(:mother_name) }
    it { should validate_presence_of(:how_long_associated_with_shivyog) }
    it { should validate_presence_of(:yearly_renumaration) }
    it { should validate_presence_of(:languages) }
    it { should validate_presence_of(:why_you_want_to_attend_this_shivir) }
    it { should validate_presence_of(:how_did_you_came_to_know_about_the_shivir) }

    context "if you are a member of political party" do
      before { allow(subject).to receive(:are_you_member_of_political_party?).and_return(true) }
      it { should validate_presence_of(:political_party_name) }
    end
    context "if you are not a member of political party" do
      before { allow(subject).to receive(:are_you_member_of_political_party?).and_return(false) }
      it { should_not validate_presence_of(:political_party_name) }
    end

    context "if you are a taking_medication" do
      before { allow(subject).to receive(:are_you_taking_medication?).and_return(true) }
      it { should validate_presence_of(:medication_details) }
    end
    context "if you are not a taking_medicatio" do
      before { allow(subject).to receive(:are_you_taking_medication?).and_return(false) }
      it { should_not validate_presence_of(:medication_details) }
    end

    context "if you are suffering from physical or mental ailments" do
      before { allow(subject).to receive(:are_you_suffering_from_physical_or_mental_ailments?).and_return(true) }
      it { should validate_presence_of(:ailment_details) }
    end
    context "if you are not suffering from physical or mental ailments" do
      before { allow(subject).to receive(:are_you_suffering_from_physical_or_mental_ailments?).and_return(false) }
      it { should_not validate_presence_of(:ailment_details) }
    end

    context "if you are involved in any litigation cases" do
      before { allow(subject).to receive(:are_you_involved_in_any_litigation_cases?).and_return(true) }
      it { should validate_presence_of(:case_details) }
    end
    context "if you are not involved in any litigation cases" do
      before { allow(subject).to receive(:are_you_involved_in_any_litigation_cases?).and_return(false) }
      it { should_not validate_presence_of(:case_details) }
    end

    context "if you would like to participate in the devine mission of shivyog" do
      before { allow(subject).to receive(:would_you_like_to_participate_in_the_devine_mission_of_shivyog?).and_return(true) }
      it { should validate_presence_of(:participation_details) }
    end
    context "if you would like to participate in the devine mission of shivyog" do
      before { allow(subject).to receive(:would_you_like_to_participate_in_the_devine_mission_of_shivyog?).and_return(false) }
      it { should_not validate_presence_of(:participation_details) }
    end

    it { should validate_presence_of(:accepted_terms_and_conditions).on(:update) }
    it { should validate_presence_of(:signature).on(:update) }

  end

  it { should accept_nested_attributes_for(:special_event_sadhak_profile_references).allow_destroy(true) }
  it { should serialize(:accepted_terms_and_conditions) }
end