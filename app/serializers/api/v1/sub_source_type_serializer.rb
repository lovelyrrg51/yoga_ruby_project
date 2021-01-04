module Api::V1
  class SubSourceTypeSerializer < ActiveModel::Serializer
    attributes :id, :sub_source_name, :source_info_type_id
  end
end
