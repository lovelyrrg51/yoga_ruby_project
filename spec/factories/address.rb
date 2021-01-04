FactoryBot.define do
  factory(:address) do
    address_type nil
    addressable_id nil
    addressable_type "SadhakProfile"
    city { DbCity.first || association(:db_city) }
    country { DbCountry.first || association(:db_country) }
    deleted_at nil
    district nil
    first_line "Shiv Lok Dham"
    lat nil
    lng nil
    other_city nil
    other_state nil
    postal_code nil
    sadhak_profile_id nil
    second_line "ToFactory: RubyParser exception parsing this attribute"
    state { DbState.first || association(:db_state) }
  end
end
