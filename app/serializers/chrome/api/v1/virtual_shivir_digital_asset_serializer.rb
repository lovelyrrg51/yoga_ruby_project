class Chrome::Api::V1::VirtualShivirDigitalAssetSerializer < ActiveModel::Serializer
  attributes :id, :asset_name, :asset_description, :asset_type, :collection_id, :video_id, :digital_asset_secret_id, :author, :language, :available_for, :asset_file_size, :asset_url

  # embed :ids

	has_many :event_types, serializer: Chrome::Api::V1::DigitalAssetEventTypeSerializer, include: true


	private
	
	def asset_file_size
		object.try(:digital_asset_secret).try(:asset_file_size)
	end

	def video_id
		object.try(:digital_asset_secret).try(:video_id)
	end

	def asset_url
		object.try(:digital_asset_secret).try(:asset_url)
	end

end