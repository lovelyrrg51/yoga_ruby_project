class Attachment < ApplicationRecord
  acts_as_paranoid

  belongs_to :attachable, polymorphic: true
  validates :attachable_type, :attachable_id, presence: true, on: :update
  mount_uploader :content, FileUploader

  def s3_url
    content.url
  end

  def s3_filepath
    self[:s3_url]
  end

  # Class method
  def upload_file(options = {})
    self.class.upload_file(options)
  end

  def self.upload_file(options = {})

    # file_name, file_path, content, bucket_name, is_secure, attachable_id, attachable_type, file_type, prefix
    # Set default options
    is_secure = options[:is_secure] == false ? options[:is_secure] : true

    raise SyException.new("No options for file upload.") unless options.present?

    # Access Bucket
    bucket = Aws::S3::Bucket.new(options[:bucket_name])
    raise SyException.new("Bucket not found error.") unless bucket.exists?

    # Genearte s3 file path
    s3_file_path = options[:prefix].present? ? "#{options[:prefix]}/#{Time.now.to_i}-#{options[:file_name]}" : "#{Time.now.to_i}-#{options[:file_name]}"

    if options[:file_path].present? && File.exists?(options[:file_path])
      file = File.open(options[:file_path], "r")
    elsif options[:content].present?
      file = options[:content]
    else
      raise SyException, "File does not exist."
    end
    # Upload file to s3
    s3_file = bucket.put_object(acl: is_secure ? 'private' : 'public-read', body: file, content_type: options[:file_type], key: s3_file_path)
    raise SyException.new("Something went wrong while uploading asset. Please try again.") unless s3_file.exists?

    # Create a attachment entry
    @attachment = Attachment.create(name: options[:file_name], s3_url: s3_file.public_url.to_s, s3_path: s3_file.key, is_secure: is_secure, s3_bucket: options[:bucket_name], attachable_id: options[:attachable_id], attachable_type: options[:attachable_type], file_type: options[:file_type], file_size: options[:content].size)
    raise SyException.new(@attachment.errors.to_a.first) unless @attachment.errors.empty?

    @attachment
  end

end
