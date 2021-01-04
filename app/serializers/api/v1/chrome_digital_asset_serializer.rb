module Api::V1
  class ChromeDigitalAssetSerializer < ActiveModel::Serializer
    attributes :id, :asset_name, :asset_description, :asset_type, :asset_list_thumbnail_url, :asset_large_thumbnail_url, :collection_id, :language, :published_on, :expires_at
    #embed :ids
  
  	has_many :event_types
  end
end
