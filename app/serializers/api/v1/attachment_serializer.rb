module Api::V1
  class AttachmentSerializer < ActiveModel::Serializer
    attributes :id, :name, :file_size, :file_type, :s3_url, :s3_path, :s3_bucket, :attachable_id, :attachable_type
  #   has_one :attachable, include: true
  end
end
