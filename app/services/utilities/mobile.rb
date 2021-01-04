# frozen_string_literal: true

module Utilities
  class Mobile
    INDIA = 'IN'
    attr_reader :number, :country

    def initialize number, country = nil
      @number = number.to_s.strip
      @country = country.presence || INDIA
    end

    def valid?
      parse.valid?
    end

    def parsed_number
      @parsed_number ||= valid? ? parse.full_e164 : parse.original
    end

    def masked_number
      @masked_number ||= parsed_number.dup.tap { |p| p[0..-5] = '********' }
    end

    def parsed_country
      parse.country
    end

    def india_number?
      parsed_country == INDIA
    end

    private

    def parse
      @parse ||=
        case
        when Phonelib.valid?(number)
          Phonelib.parse(number)
        when Phonelib.valid_for_country?(number, country)
          Phonelib.parse(number, country)
        else
          Phonelib.parse(number)
        end
    end

  end
end
