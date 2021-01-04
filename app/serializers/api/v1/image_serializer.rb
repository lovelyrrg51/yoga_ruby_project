module Api::V1
  class ImageSerializer < ActiveModel::Serializer
    attributes :id, :name, :s3_url, :imageable_id, :imageable_type, :is_secure
  
    # Send s3_url only if logged in user is present - 18 Jan 2017
    def s3_url
      if $current_user.present?
        object.get_s3_secure_url
      else
        nil
      end
    end
  
  end
end
