module Api::V1
  
  class S3NewBucketController < BaseController
    before_action :authenticate_user!
  
    def index
      bucket = Aws::S3::Bucket.new('syportalaudiobucket') # no request made
      obj_names = bucket.objects.map{|obj| {"id" => "0", "name" => obj.key, 'download_url' => obj.presigned_url(:get, :secure => false).to_s} }
      render json: obj_names.to_json
    end
  end
end
