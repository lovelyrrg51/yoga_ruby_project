# frozen_string_literal: true

class GetSenderEmail
  SUPPORTED_TYPES = %w[Event SyClub SadhakProfile]

  def self.call object
    if object.class.to_s.in?(SUPPORTED_TYPES)
      in_india = object.try(:address).try(:country_id) == 113
      in_india ? 'registration@shivyogindia.com' : 'support@absclp.com'
    else
      'support@absclp.com'
    end
  end

end
