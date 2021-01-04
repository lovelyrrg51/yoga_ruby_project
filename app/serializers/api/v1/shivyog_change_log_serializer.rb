module Api::V1
  class ShivyogChangeLogSerializer < ActiveModel::Serializer
    attributes :id, :attribute_name, :value_before, :value_after, :description, :change_loggable_id, :change_loggable_type
  end
end
