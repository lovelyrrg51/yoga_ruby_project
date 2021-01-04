class FileUploader < CarrierWave::Uploader::Base

  # Callbacks
  # after :cache, :retrieve_from_cache, :store, :retrieve_from_store, :remove
  after :store, :update_attachment_model


  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    self.fog_directory = bucket_name 
    "#{ENV['ENVIRONMENT']}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  
    "/images/fallback/" + [version_name, "profile.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process resize_to_fit: [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg png doc docx xls xlsx pdf csv)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def size_range
    1..MAX_ATTACHMENT_FILE_SIZE
  end

  def update_attachment_model(f)
    model.update_columns(name: file.filename, s3_url: file.public_url.to_s, s3_path: file.path.to_s, is_secure: true, s3_bucket: ENV['ATTACHMENT_BUCKET'])
  end

  def fog_public
    true
  end

private
  def bucket_name
    ENV['ATTACHMENT_BUCKET']
  end

end
