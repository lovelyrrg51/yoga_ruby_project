module Api::V1
  class DigitalAssetSecretSerializer < ActiveModel::Serializer
    attributes :id, :video_id, :embed_code, :asset_dl_url , :asset_hls_url, :asset_sd_url, :asset_mobile_url, :asset_file_name, :asset_url, :asset_file_size
    
    # embed :id
    has_one :digital_asset
  end
end
