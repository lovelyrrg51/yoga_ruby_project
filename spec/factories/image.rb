FactoryBot.define do
  factory(:image) do
    deleted_at nil
    imageable_id 1
    imageable_type "AdvanceProfilePhotograph"
    is_secure false
    name "AVDHOOT1.jpg"
    s3_bucket "syregportalprofilepictures"
    s3_path "1423703044-AVDHOOT1.jpg"
    s3_url "https://syregportalprofilepictures.s3.amazonaws.com/1423703044-AVDHOOT1.jpg"
  end
end
