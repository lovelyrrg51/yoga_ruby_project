FactoryBot.define do
  factory(:sadhak_profile) do
    address_proof nil
    address_proof_status "ap_pending"
    any_legal_proceedings nil
    attended_any_shivir nil
    avatar_content_type nil
    avatar_file_name nil
    avatar_file_size nil
    avatar_updated_at nil
    date_of_birth "1990-01-01"
    deleted_at nil
    email "test1@yopmail.com"
    email_verification_token nil
    faith nil
    first_name "Prince"
    gender "male"
    is_approved_for_mega_events false
    is_approved_for_virtual_events false
    is_email_verified false
    is_mobile_verified false
    is_under_age false
    last_name "Bansal"
    marital_status "single"
    middle_name nil
    mobile nil
    mobile_verification_token nil
    name_of_guru nil
    occupation_type ""
    ownership_request_token nil
    phone ""
    photo_id_proof nil
    spiritual_org_name nil
    status nil
    syid nil
    user nil
    username nil
    visit_id nil
  end
end