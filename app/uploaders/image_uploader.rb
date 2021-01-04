class ImageUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  after :store, :update_image_model
  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
     if model.new_record? || (model.persisted? && model.saved_changes?) then
     	self.fog_directory = bucket_name
     	"#{ENV['ENVIRONMENT']}/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
     else
     	self.fog_directory = model.s3_bucket.presence || ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET']
     	File.dirname(model.s3_path) == '.' ? '' : File.dirname(model.s3_path)
     end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(*args)
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  
    "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  def filename
  	original_filename.present? ? File.basename(original_filename, File.extname(original_filename)).gsub(/[^a-zA-Z0-9]/,'') + File.extname(original_filename) : ''
  end

  def full_filename(for_file = model)
  	
  	if model.new_record? || (model.persisted? && model.saved_changes?)
			super
		else
			# binding.pry
				# for_file
			 model.read_attribute(:s3_path).split('/').last
		end
  end

  # Process files as they are uploaded:
  # process scale: [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :thumb do
    process resize_to_fit: [100, 100]

	  def full_filename(for_file = model)
  		if model.new_record? || (model.persisted? && model.saved_changes?)
				super
  		else
				'thumb_'+ filename #model.read_attribute(:s3_path).split('/').last || for_file
  		end
	  end

	  def filename
		  if model.new_record? || (model.persisted? && model.saved_changes?)
		  	super
		  else
		  	
		    (base_filename = model.read_attribute(mounted_as)).present? ? File.basename(base_filename, File.extname(base_filename)).gsub(/[^a-zA-Z0-9]/,'') + File.extname(base_filename) : ''
		  end
	  end
  end

	# def store_path(for_file=filename)
	# 	if store_dir.present?
	# 	File.join([store_dir, full_filename(for_file)].compact)
	# 	else
	# 		[store_dir, full_filename(for_file)].compact.join
	# 	end
	# end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg png)
  end

  def size_range
    1..MAX_ATTACHMENT_FILE_SIZE
  end

  def update_image_model(f)
    model.update_columns(s3_url: file.public_url.to_s, s3_path: file.path.to_s, is_secure: true, s3_bucket: fog_directory)
  end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
 


private
  def bucket_name
    case  model.imageable_type
      when "AdvanceProfilePhotograph"
        ENV['REGISTRATION_PROFILE_PICTURES_BUCKET']
      when "AdvanceProfileIdentityProof"
        ENV['REGISTRATION_IDENTITY_PROOFS_BUCKET']
      when "AdvanceProfileAddressProof"
        ENV['REGISTRATION_ADDRESS_PROOFS_BUCKET']
      else
        ENV['ATTACHMENT_BUCKET']
    end   

  end

end
