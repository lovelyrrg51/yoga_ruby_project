require 'rails_helper'
RSpec.describe SadhakProfile, type: :model do
  it { is_expected.to act_as_paranoid }
  let(:sadhak_profile) { described_class.new }

  describe "associations" do
    context 'for belongs to' do
      it { should belong_to(:user).optional }
    end

    context 'for has one' do
      it { should have_one(:advisory_counsil) }
      it { should have_one(:address) }
      it { should have_one(:professional_detail).dependent(:destroy) }
      it { should have_one(:profession).through(:professional_detail).source(:profession) }
      it { should have_one(:spiritual_practice).dependent(:destroy) }
      it { should have_one(:aspects_of_life).dependent(:destroy) }
      it { should have_one(:shivyog_journey).dependent(:destroy) }
      it { should have_one(:doctors_profile).dependent(:destroy) }
      it { should have_one(:advance_profile).dependent(:destroy) }
      it { should have_one(:spiritual_journey).dependent(:destroy) }
      it { should have_one(:medical_practitioners_profile).dependent(:destroy) }
      it { should have_one(:sadhak_seva_preference).dependent(:destroy) }
    end

    context 'for has many' do
      it { should have_many(:relations).dependent(:destroy) }
      it { should have_many(:users).conditions(relations: {is_verified: true}).through(:relations).source(:user) }
      it { should have_many(:other_spiritual_associations).dependent(:destroy) }
      it { should have_many(:shivyog_change_logs).dependent(:destroy) }
      it { should have_many(:event_registrations).dependent(:destroy) }
      it { should have_many(:valid_event_registrations).conditions(status: EventRegistration.valid_registration_statuses).class_name('EventRegistration') }
      it { should have_many(:events).through(:valid_event_registrations).source(:event) }
      it { should have_many(:valid_event_registrations_without_clp).conditions(status: EventRegistration.valid_registration_statuses).class_name('EventRegistration') }
      it { should have_many(:events_without_clp).through(:valid_event_registrations_without_clp).source(:event) }
      it { should have_many(:window_events).conditions(%q{events.event_start_date - integer '5' <= CURRENT_DATE AND events.event_end_date + integer '2' >= CURRENT_DATE}).through(:valid_event_registrations_without_clp).source(:event) }
      # it { should have_many(:renewal_events) } # table is not exist
      it { should have_many(:event_references).dependent(:destroy) }
      it { should have_many(:event_sponsors).dependent(:destroy) }
      it { should have_many(:sy_club_sadhak_profile_associations).dependent(:destroy) }
      it { should have_many(:sy_clubs).through(:sy_club_sadhak_profile_associations) }
      it { should have_many(:sy_club_references).dependent(:destroy) }
      it { should have_many(:reference_clubs).through(:sy_club_references).source(:sy_club) }
      it { should have_many(:sy_club_members).dependent(:destroy) }
      it { should have_many(:joined_clubs).through(:sy_club_members).source(:sy_club) }
      it { should have_many(:special_event_sadhak_profile_other_infos).dependent(:destroy) }
      it { should have_many(:forum_memberships).conditions(sy_club_members: {status: SyClubMember.statuses[:approve]}).with_foreign_key('sadhak_profile_id').class_name('SyClubMember') }
      it { should have_many(:sadhak_profile_attended_shivirs).dependent(:destroy) }
    end
  end

  describe "delegate" do
    it { should delegate_method(:name).to(:profession).with_prefix('profession').allow_nil }
    it { should delegate_method(:full_address).to(:address).allow_nil }
    it { should delegate_method(:street_address).to(:address).allow_nil }
    it { should delegate_method(:country_name).to(:address).allow_nil }
    it { should delegate_method(:state_name).to(:address).allow_nil }
    it { should delegate_method(:city_name).to(:address).allow_nil }
    it { should delegate_method(:country_currency_code).to(:address).allow_nil }
    it { should delegate_method(:country_telephone_prefix).to(:address).allow_nil }
    it { should delegate_method(:country_ISO2).to(:address).allow_nil }
    it { should delegate_method(:postal_code).to(:address).allow_nil }
    it { should delegate_method(:advance_profile_s3_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:advance_profile_identity_proof_s3_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:advance_profile_address_proof_s3_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:advance_profile_thumb_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:advance_profile_identity_proof_thumb_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:advance_profile_address_proof_thumb_url).to(:advance_profile).allow_nil }
    it { should delegate_method(:photo_id_proof_type_name).to(:advance_profile).allow_nil }
    it { should delegate_method(:address_proof_type_name).to(:advance_profile).allow_nil }
    it { should delegate_method(:photo_id_proof_number).to(:advance_profile).allow_nil }
  end

  it { should accept_nested_attributes_for(:spiritual_practice) }
  it { should accept_nested_attributes_for(:professional_detail) }
  it { should accept_nested_attributes_for(:medical_practitioners_profile) }
  it { should accept_nested_attributes_for(:sadhak_seva_preference) }
  it { should accept_nested_attributes_for(:spiritual_journey) }
  it { should accept_nested_attributes_for(:special_event_sadhak_profile_other_infos) }
  it { should accept_nested_attributes_for(:address).allow_destroy(true) }
  it { should accept_nested_attributes_for(:advance_profile).allow_destroy(true) }
  it { should accept_nested_attributes_for(:doctors_profile) }


  describe "enum" do
    it { should define_enum_for(:profile_photo_status).with_values({pp_pending: 0, pp_success: 1, pp_rejected: 2}) }
    it { should define_enum_for(:photo_id_status).with_values({pi_pending: 0, pi_success: 1, pi_rejected: 2}) }
    it { should define_enum_for(:address_proof_status).with_values({ap_pending: 0, ap_success: 1, ap_rejected: 2}) }
    it { should define_enum_for(:status).with_values({temporary_blocked: 0, banned: 1, pending_approval: 2, approved: 3}) }
  end

  describe 'aasm states' do
    sadhak_profile = FactoryBot.build(:sadhak_profile)
    it { should have_state(:pp_pending).on(:aasm_profile_photo_status)  }
    it { should have_state(:pi_pending).on(:aasm_photo_id_status)  }
    it { should have_state(:ap_pending).on(:aasm_address_proof_status)  }

    it "should transform from ap_pending to ap_success" do
      expect(sadhak_profile).to transition_from(:ap_pending).to(:ap_success).on_event(:ap_approve).on(:aasm_address_proof_status)
    end

    it "should transform from ap_pending to ap_rejected" do
      expect(sadhak_profile).to transition_from(:ap_pending).to(:ap_rejected).on_event(:ap_reject).on(:aasm_address_proof_status)
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_length_of(:first_name).is_at_most(255).is_at_least(2) }
    it { should allow_value('test test').for(:first_name).with_message("Only allows letters.") }
    it { should allow_value('test test').for(:last_name).with_message("Only allows letters.") }
    it { should allow_value('test@test.com').for(:email).with_message("is not valid.") }

    describe 'mobile or email must be present' do
      before { sadhak_profile.validate }
      subject { sadhak_profile.errors.full_messages }

      context 'email is present, mobile is not' do
        let(:sadhak_profile) { SadhakProfile.new email: 'test@example.com', mobile: '' }
        it { is_expected.not_to include 'Mobile or Email must be provided' }
      end

      context 'mobile is present, email is not' do
        let(:sadhak_profile) { SadhakProfile.new email: '', mobile: '123456789' }
        it { is_expected.not_to include 'Mobile or Email must be provided' }
      end

      context 'mobile and email are blank' do
        let(:sadhak_profile) { SadhakProfile.new email: '', mobile: '' }
        it { is_expected.to include 'Mobile or Email must be provided' }
      end
    end
  end

  describe 'date_of_birth' do
    subject { sadhak_profile.errors.full_messages }

    context 'when date_of_birth is invalid string' do
      before do
        sadhak_profile.date_of_birth = 'random'
        sadhak_profile.validate
      end
      it { is_expected.to include 'Date of birth is not a valid date' }
    end

    context 'when date_of_birth is on or after today' do
      before do
        sadhak_profile.date_of_birth = Date.today
        sadhak_profile.validate
      end
      it { is_expected.to include "Date of birth must be before #{Date.today}" }
    end

    context 'when date_of_birth is before 1900' do
      before do
        sadhak_profile.date_of_birth = Date.new(1899, 12, 31)
        sadhak_profile.validate
      end
      it { is_expected.to include 'Date of birth must be on or after 1900-01-01' }
    end
  end

  describe "set constants" do
    before { stub_const("#{described_class}", sadhak_profile) }
    it { expect(described_class::REQUIRED_FIELD_FOR_BASIC_PROFILE).to eq([:first_name, :gender, :date_of_birth]) }
    it { expect(described_class::REQUIRED_FIELD_FOR_NAME_OF_GURU).to eq([:name_of_guru, :spiritual_org_name]) }
    it { expect(described_class::SADHAK_PROFILE_SINGLE_ASSOCIATED_MODELS).to eq([:aspects_of_life, :advance_profile, :sadhak_seva_preference]) }
  end

end
