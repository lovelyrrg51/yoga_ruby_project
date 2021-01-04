module Api::V1
  class PaginationSerializer < ActiveModel::Serializer::CollectionSerializer
    def initialize(object, options={})
      meta_key = options[:meta_key] || :meta
      options[meta_key] = {}
      options[meta_key][:pagination] = {
        current_page: object.try(:current_page),
        next_page: object.try(:next_page),
        prev_page: object.try(:prev_page),
        total_pages: object.try(:total_pages),
        total_count: object.try(:total_count),
        first_page: object.try(:first_page?),
        last_page: object.try(:last_page?),
        out_of_range: object.try(:out_of_range?)
      }
      super(object, options)
    end
  end
end
