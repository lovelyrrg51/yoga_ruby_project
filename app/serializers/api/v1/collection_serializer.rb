module Api::V1
  class CollectionSerializer < ActiveModel::Serializer
    attributes :id, :source_asset_id, :collection_name, :collection_description, :digital_asset_ids
    #embed :ids
    # has_many :digital_assets
  end
end
