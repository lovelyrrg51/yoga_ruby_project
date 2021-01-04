  class Chrome::Api::V2::CollectionSerializer < ActiveModel::Serializer

    attributes :id, :collection_name, :collection_description, :digital_asset_ids, :digital_asset_seq, :collection_type, :announcement_text

    has_many :digital_assets, serializer: Chrome::Api::V2::DigitalAssetSerializer, include: true 

    def digital_asset_seq
      object.try(:episodes).try(:pluck, :id) || []
    end
    
end
