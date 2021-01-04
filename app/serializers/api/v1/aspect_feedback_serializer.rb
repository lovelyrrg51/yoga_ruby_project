module Api::V1
  class AspectFeedbackSerializer < ActiveModel::Serializer
    attributes :id, :aspect_type, :rating_before, :rating_after, :name
  end
end
