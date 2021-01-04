module Api::V1
  class TagCollectionSerializer < ActiveModel::Serializer
    attributes :id, :name, :priority, :menu_id
    #embed :ids
    has_many :asset_tags
  end
end
