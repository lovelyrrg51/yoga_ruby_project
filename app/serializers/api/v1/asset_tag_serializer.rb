module Api::V1
  class AssetTagSerializer < ActiveModel::Serializer
    attributes :id, :tag, :tag_priority, :tag_collection_id, :thumbnail_url, :thumbnail_path
    
    #embed :ids
    has_many :digital_assets
  end
end
