module Api::V1
  class AspectsOfLifeSerializer < ActiveModel::Serializer
    attributes :id, :sadhak_profile_id
    
    has_many :aspect_feedbacks, include: true
    #embed :ids
  end
end
