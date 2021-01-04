# frozen_string_literal: true

class EditSadhakProfilePresenter
  attr_reader :sadhak_profile, :address

  def initialize sadhak_profile
    @sadhak_profile = sadhak_profile
    @address = sadhak_profile.address || sadhak_profile.build_address
  end

  def as_json options = {}
    {
      sadhak_profile: {
        first_name: sadhak_profile.first_name,
        last_name: sadhak_profile.last_name,
        gender: sadhak_profile.gender,
        date_of_birth: sadhak_profile.date_of_birth,
        email: sadhak_profile.email,
        mobile: sadhak_profile.mobile,
      },
      address: {
        first_line: address.first_line,
        second_line: address.second_line,
        city_id: address.city_id,
        state_id: address.state_id,
        country_id: address.country_id,
        other_state: address.other_state,
        other_city: address.other_city,
        postal_code: address.postal_code,
      }
    }
  end

end
