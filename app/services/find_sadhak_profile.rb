# frozen_string_literal: true

class FindSadhakProfile

  # query could be syid, email or mobile number
  def self.by_query query
    return if query.blank?

    query.strip!

    case
    when query =~ /SY[1-9]+[0-9]*/i
      SadhakProfile.find_by syid: query.upcase
    when query =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
      SadhakProfile.find_by email: query.downcase
    # when query =~ /\A(?:\+?\d{1,3}\s*-?)?\(?(?:\d{3})?\)?[- ]?\d{3}[- ]?\d{4}\z/i
    else
      mobile = Utilities::Mobile.new(query).parsed_number
      SadhakProfile.find_by mobile: mobile
    end
  end

  def self.by_query_and_first_name query, first_name
    return unless sadhak_profile = by_query(query)
    sadhak_profile if sadhak_profile.first_name.downcase == first_name.strip.downcase
  end

end
