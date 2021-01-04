class Chrome::Api::V1::ForumDigitalAssetSerializer < ActiveModel::Serializer
  attributes :id, :asset_name, :asset_description, :asset_type, :price, :collection_id, :video_id, :is_owned, :digital_asset_secret_id, :author, :language, :available_for, :asset_file_size, :asset_url

  # embed :ids

	has_one :digital_asset_secret

end