module Api::V1
  class PhysicalExerciseTypeSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
