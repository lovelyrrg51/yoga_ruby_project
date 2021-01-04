module Api::V1
  class GlobalPreferenceSerializer < ActiveModel::Serializer
     attributes :id, :key, :val, :alias_name
  end
end
