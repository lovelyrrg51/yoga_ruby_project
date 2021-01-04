# frozen_string_literal: true

class CreateSadhakProfile

  def self.call sadhak_profile_params:, address_params:, user:
    sadhak_profile = SadhakProfile.new(sadhak_profile_params)

    relation = Relation.new(
      user: user,
      sadhak_profile: sadhak_profile,
      relationship_type: 'group_member',
      is_verified: true
    )

    sadhak_profile.build_user(
      name: sadhak_profile.first_name,
      last_name: sadhak_profile.last_name,
      password: Devise.friendly_token.first(8),
      date_of_birth: sadhak_profile.date_of_birth,
      gender: sadhak_profile.gender,
      email: sadhak_profile.email || '',
      contact_number: sadhak_profile.mobile,
      country_id: address_params[:country_id],
    )

    address = Address.new address_params
    address.addressable = sadhak_profile

    ApplicationRecord.transaction do
      sadhak_profile.save!
      relation.save!
      address.save!
    end

    OpenStruct.new(success: true, sadhak_profile: sadhak_profile.reload)
  rescue => e
    Rollbar.error(e)
    OpenStruct.new(success: false, sadhak_profile: sadhak_profile, error: e)
  end

end
