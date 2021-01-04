class Chrome::Api::V2::DigitalAssetSerializer < ActiveModel::Serializer

    attributes :id, :asset_name, :asset_description, :asset_url, :asset_file_size, :collection_id, :expires_at

    def asset_url
        object.digital_asset_secret.try(:asset_url)
    end
    
end


