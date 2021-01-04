module Api::V1
  class S3ThumbnailsController < BaseController
    before_action :authenticate_user!
  
    def index
      bucket = Aws::S3::Bucket.new(ENV['ASSET_TAG_THUMBNAIL_BUCKET'])
      arr = []
      id = 1
      bucket.objects.each do |content|
        toPush = {'thumbnail_url' => nil, 'thumbnail_path' => nil, 'id' => id}
        toPush['thumbnail_url'] = ENV['THUMBNAIL_CLOUDFRONT_URL'].to_s() + content.key.to_s()
        toPush['thumbnail_path'] = content.key
        arr.push(toPush)
        id += 1
      end
      render json: arr
    end
  end
end
