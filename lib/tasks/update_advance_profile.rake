namespace :update_advance_profile do
  desc "TODO"
  task update_address_proof_type_id: :environment do
    AdvanceProfile.all.each do |advance_profile|
      APT = AddressProofType.find_by(name: advance_profile.address_proof_type)
      advance_profile.update_attribute(:address_proof_type_id, APT.id)
    end
  end

  desc "TODO"
  task update_photo_id_proof_type_id: :environment do
    AdvanceProfile.all.each do |advance_profile|
      PIT = PhotoIdType.find_by(name: advance_profile.photo_id_proof_type)
      advance_profile.update_attribute(:photo_id_proof_type_id, PIT.id)
    end
  end
  
  desc "TODO"
  task update_advance_profile_attributes: [:update_address_proof_type_id, :update_photo_id_proof_type_id] do
      puts "Successfully updated"
  end
end