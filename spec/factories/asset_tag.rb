FactoryBot.define do
  factory(:asset_tag) do
    digital_asset_id nil
    tag "Health"
    tag_collection_id 2
    tag_priority 1
    thumbnail_path "thumbnail-mindbodyhealth.jpg"
    thumbnail_url "http://d2ak50xrsp1mx3.cloudfront.net/thumbnail-mindbodyhealth.jpg"
  end
end
