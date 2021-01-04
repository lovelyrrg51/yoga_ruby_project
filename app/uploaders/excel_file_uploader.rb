class ExcelFileUploader < CarrierWave::Uploader::Base

  # Callbacks
  # after :cache, :retrieve_from_cache, :store, :retrieve_from_store, :remove

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
    "#{ENV['ENVIRONMENT']}/offline_forum_data_migration/#{Date.today.strftime("%d-%m-%Y")}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  
    "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(xls xlsx)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   self.new_filename if original_filename
  # end

  def size_range
    1..MAX_ATTACHMENT_FILE_SIZE / 5
  end

private
  def bucket_name
    ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET']
  end

end
