FactoryBot.define do
  factory(:relation) do
    deleted_at nil
    is_verified true
    relationship_type "group_member"
    sadhak_profile_id 1
    syid nil
    user_id 1
    verification_code nil
  end
end
