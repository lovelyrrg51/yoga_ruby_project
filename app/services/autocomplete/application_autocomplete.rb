module Autocomplete
  class ApplicationAutocomplete
    delegate :params, to: :@view

    def initialize(view)
      @view = view
    end

    def as_json(options = {})
      [].tap do |column|
        results.each do |result|
          json = {}
          json[:label] = result_partial(result)
          json[:value] = result_value(result)
          column << json
        end
      end
    end

  end
end
