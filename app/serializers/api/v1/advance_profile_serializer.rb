module Api::V1
  class AdvanceProfileSerializer < ActiveModel::Serializer
    attributes :id, :faith, :any_legal_proceeding, :attended_any_shivir, :photograph_url, :photograph_path, :photo_id_proof_number, :photo_id_proof_url, :photo_id_proof_path,  :address_proof_url, :address_proof_path, :sadhak_profile_id, :address_proof_type_id, :photo_id_proof_type_id
  
    #embed :ids
    has_one :advance_profile_photograph, include: true
    has_one :advance_profile_identity_proof, include: true
    has_one :advance_profile_address_proof, include: true
  
    def photograph_url
      if $current_user.present?
        advance_profile_photograph.try(:s3_url)
      else
        nil
      end
    end
  end
end
