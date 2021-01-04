module Api::V1
  class SourceInfoTypeSerializer < ActiveModel::Serializer
    attributes :id, :source_name
  end
end
