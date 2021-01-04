module Api::V1
  class ProfessionSerializer < ActiveModel::Serializer
    attributes :id, :name, :code
  end
end
