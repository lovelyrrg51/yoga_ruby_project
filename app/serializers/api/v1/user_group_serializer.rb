module Api::V1
  class UserGroupSerializer < ActiveModel::Serializer
    attributes :id, :name
    
    #embed :ids
    has_many :users
    has_many :digital_assets
  end
end
