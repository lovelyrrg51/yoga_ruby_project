class AdvanceProfile < ApplicationRecord

  acts_as_paranoid

  REQUIRED_FIELD = [:faith, :photo_id_proof_type_id, :photo_id_proof_number, :advance_profile_photograph, :advance_profile_identity_proof]

  delegate :s3_url, to: :advance_profile_photograph, allow_nil: true, prefix: 'advance_profile'
  delegate :s3_url, to: :advance_profile_identity_proof, allow_nil: true, prefix: 'advance_profile_identity_proof'
  delegate :s3_url, to: :advance_profile_address_proof, allow_nil: true, prefix: 'advance_profile_address_proof'
  delegate :thumb_url, to: :advance_profile_photograph, allow_nil: true, prefix: 'advance_profile'
  delegate :thumb_url, to: :advance_profile_identity_proof, allow_nil: true, prefix: 'advance_profile_identity_proof'
  delegate :thumb_url, to: :advance_profile_address_proof, allow_nil: true, prefix: 'advance_profile_address_proof'
  delegate :name, to: :photo_id_type, allow_nil: :true, prefix: 'photo_id_proof_type'
  delegate :name, to: :address_proof_type, allow_nil: :true, prefix: 'address_proof_type'
  
  validates :sadhak_profile_id, uniqueness: true
  belongs_to :sadhak_profile
  belongs_to :photo_id_type, foreign_key: :photo_id_proof_type_id
  belongs_to :address_proof_type, foreign_key: :address_proof_type_id
  after_save :advance_profile_after_save
  after_initialize :set_default_values

  has_one :advance_profile_photograph, lambda { where(images: { imageable_type: "AdvanceProfilePhotograph" }) }, class_name: "Image", foreign_key: "imageable_id", dependent: :destroy

  has_one :advance_profile_identity_proof, lambda { where(images: { imageable_type: "AdvanceProfileIdentityProof" }) }, class_name: "Image", foreign_key: "imageable_id", dependent: :destroy

  has_one :advance_profile_address_proof, lambda { where(images: { imageable_type: "AdvanceProfileAddressProof" }) }, class_name: "Image", foreign_key: "imageable_id", dependent: :destroy

  accepts_nested_attributes_for :advance_profile_photograph
  accepts_nested_attributes_for :advance_profile_identity_proof
  accepts_nested_attributes_for :advance_profile_address_proof
  def advance_profile_after_save
    logger.debug "in ap"
    self.sadhak_profile.check_profile_completeness
  end

  def self.faith_options
    %w(Buddhism Christianity Hinduism Islam Jainism Sikhism Other).map{|p| [p,p]}
  end

  def set_default_values
    self.any_legal_proceeding = false
    self.attended_any_shivir = false
  end

end
