require 'rails_helper'

RSpec.describe SyClub, type: :model do

  describe "associations" do
    it { should belong_to(:user).optional }

    context 'for has one' do
      it { should have_one(:address).dependent(:destroy) }
      it { should have_one(:sy_club_venue_detail).dependent(:destroy) }
      it { should have_one(:sy_club_digital_arrangement_detail).dependent(:destroy) }
      it { should have_one(:event_order) }
    end

    context 'for has many' do
      it { should have_many(:sy_club_sadhak_profile_associations).dependent(:destroy) }
      it { should have_many(:sadhak_profiles).through(:sy_club_sadhak_profile_associations) }
      it { should have_many(:sy_club_user_roles).through(:sy_club_sadhak_profile_associations) }
      it { should have_many(:sy_club_references).dependent(:destroy) }
      it { should have_many(:sadhak_profile_references).through(:sy_club_references).source(:sadhak_profile) }
      it { should have_many(:sy_club_members).dependent(:destroy) }
      it { should have_many(:members).through(:sy_club_members).source(:sadhak_profile) }
      it { should have_many(:approved_members).conditions(sy_club_members: {status: SyClubMember.statuses['approve'], is_deleted: false}).source(:sadhak_profile) }
      it { should have_many(:sy_club_event_associations).dependent(:destroy) }
      it { should have_many(:events).through(:sy_club_event_associations) }
      it { should have_many(:sy_club_event_type_associations).dependent(:destroy) }
      it { should have_many(:event_types).through(:sy_club_event_type_associations) }
      it { should have_many(:stripe_subscriptions) }
      it { should have_many(:tickets).dependent(:destroy) }
      it { should have_many(:shivyog_change_logs).dependent(:destroy) }
      it { should have_many(:forum_attendance_details) }

    end
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:members_count) }
    # it { should validate_presence_of(:min_members_count) }
    it { should validate_length_of(:name).is_at_least(3) }
    # context "when a is_deleted is false" do
    #   subject { SyClub.new(is_deleted: false) }
    #   it { should validate_uniqueness_of(:name) }
    # end
    context "when a is_deleted is false" do
      subject { SyClub.new(min_members_count: 11) }
      it { should validate_numericality_of(:members_count).only_integer.is_greater_than_or_equal_to(11) }
    end
    it { should validate_numericality_of(:min_members_count).only_integer.is_greater_than_or_equal_to(0) }
  end

  describe "delegate" do
    it { should delegate_method(:full_address).to(:address).allow_nil }
    it { should delegate_method(:country_telephone_prefix).to(:address).allow_nil }
    it { should delegate_method(:state_name).to(:address).allow_nil }
    it { should delegate_method(:city_name).to(:address).allow_nil }
  end

  describe "accepts nested attributes for" do
    it { should accept_nested_attributes_for(:address).allow_destroy(true) }
    it { should accept_nested_attributes_for(:sy_club_sadhak_profile_associations).allow_destroy(true) }
    it { should accept_nested_attributes_for(:sy_club_venue_detail).allow_destroy(true) }
    it { should accept_nested_attributes_for(:sy_club_digital_arrangement_detail).allow_destroy(true) }
    it { should accept_nested_attributes_for(:sy_club_references).allow_destroy(true) }
  end

  describe "enum" do
    it { should define_enum_for(:club_level).with_values({subcity: 5, city: 4, state: 3, country: 2, global: 1}) }
    it { should define_enum_for(:status).with_values({enabled: 0, disabled: 1, capacity_reached: 2}) }
  end

  # AASM
  describe 'aasm states' do
    sy_club = FactoryBot.build(:sy_club)
    it { should have_state(:enabled) }

    it "should transform from enabled to disabled" do
      expect(sy_club).to transition_from(:enabled).to(:disabled).on_event(:disabled)
    end

    it "should transform from enabled to capacity_reached" do
      expect(sy_club).to transition_from(:enabled).to(:capacity_reached).on_event(:capacity_reached)
    end
  end

  describe 'default scope' do
    is_deleted = false
    it "should return collection whose is_deleated is false" do
      expect(is_deleted).to eq(subject.is_deleted)
    end
  end
end
