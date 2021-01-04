module Utilities
  class UniqueKeyGenerator
    ALPHANUMERIC = [*'a'..'z', *'A'..'Z', *0..9].freeze

    def self.generate length = 8
      (0...length).map{ ALPHANUMERIC.sample }.join
    end
  end
end
