module Api::V1
  class SeatingCategorySerializer < ActiveModel::Serializer
    attributes :id, :category_name
  end
end
