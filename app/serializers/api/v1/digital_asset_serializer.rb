module Api::V1
  class DigitalAssetSerializer < ActiveModel::Serializer
    attributes :id, :asset_name, :asset_description, :asset_type, :price, :asset_list_thumbnail_url, :asset_large_thumbnail_url, :collection_id, :is_collection, :collection_priority, :video_id, :is_owned, :digital_asset_secret_id, :author, :is_for_sale_on_store, :language, :published_on, :available_for, :expires_at, :asset_file_size, :asset_url
  
    #embed :ids
    has_many :asset_tags
    has_many :user_groups
    has_one :digital_asset_secret
    has_many :event_types
	def asset_url
		object.signed_asset_url
	end
  end
end
