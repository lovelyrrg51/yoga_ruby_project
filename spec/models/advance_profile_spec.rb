require 'rails_helper'

RSpec.describe AdvanceProfile, type: :model do
  let(:advance_profile) { Class.new }
  it { is_expected.to act_as_paranoid }

  describe "associations" do
    it { should belong_to(:sadhak_profile) }
    it { should belong_to(:photo_id_type).with_foreign_key(:photo_id_proof_type_id) }
    it { should belong_to(:address_proof_type).with_foreign_key(:address_proof_type_id) }
    it { should have_one(:advance_profile_photograph).conditions(images: { imageable_type: "AdvanceProfilePhotograph" }).class_name('Image').with_foreign_key(:imageable_id).dependent(:destroy) }
    it { should have_one(:advance_profile_identity_proof).conditions(images: { imageable_type: "AdvanceProfileIdentityProof" }).class_name('Image').with_foreign_key(:imageable_id).dependent(:destroy) }
    it { should have_one(:advance_profile_address_proof).conditions(images: { imageable_type: "AdvanceProfileAddressProof" }).class_name('Image').with_foreign_key(:imageable_id).dependent(:destroy) }
    it{ should accept_nested_attributes_for :advance_profile_photograph }
    it{ should accept_nested_attributes_for :advance_profile_identity_proof }
    it{ should accept_nested_attributes_for :advance_profile_address_proof }
  end
  # describe "validations" do
  #   it { should validate_uniqueness_of(:sadhak_profile_id) }
  # end

  describe 'delegate methods' do
    it { should delegate_method(:s3_url).to(:advance_profile_photograph).allow_nil.with_prefix('advance_profile') }
    it { should delegate_method(:s3_url).to(:advance_profile_identity_proof).allow_nil.with_prefix('advance_profile_identity_proof') }
    it { should delegate_method(:s3_url).to(:advance_profile_address_proof).allow_nil.with_prefix('advance_profile_address_proof') }
    it { should delegate_method(:thumb_url).to(:advance_profile_photograph).with_prefix('advance_profile').allow_nil }
    it { should delegate_method(:thumb_url).to(:advance_profile_identity_proof).with_prefix('advance_profile_identity_proof').allow_nil }
    it { should delegate_method(:thumb_url).to(:advance_profile_address_proof).with_prefix('advance_profile_address_proof').allow_nil }
    it { should delegate_method(:name).to(:photo_id_type).with_prefix('photo_id_proof_type').allow_nil }
    it { should delegate_method(:name).to(:address_proof_type).with_prefix('address_proof_type').allow_nil }
  end

  describe "set constants" do
    before { stub_const("#{described_class}", advance_profile) }
    it { expect(described_class::REQUIRED_FIELD).to eq([:faith, :photo_id_proof_type_id, :photo_id_proof_number, :advance_profile_photograph, :advance_profile_identity_proof]) }
  end
end