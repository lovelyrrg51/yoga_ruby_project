FactoryBot.define do
  factory(:advance_profile) do
    address_proof_path ""
    address_proof_type "Ration Card"
    address_proof_type_id nil
    address_proof_url ""
    any_legal_proceeding false
    attended_any_shivir false
    deleted_at nil
    faith "Buddhism"
    photo_id_proof_number "123456"
    photo_id_proof_path ""
    photo_id_proof_type "Pan Card"
    photo_id_proof_type_id nil
    photo_id_proof_url ""
    photograph_path ""
    photograph_url "https://syregportalprofilepictures.s3.amazonaws.com/1423703044-AVDHOOT1.jpg"
    sadhak_profile_id 2
  end
end
