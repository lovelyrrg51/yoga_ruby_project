module Api::V1
  class ImagesController < BaseController
    # Allowed upload_advance_profile_identity_proof, upload_advance_profile_address_proof calls for non logged in when we made Advance profile mandaterory - Jan 17, 2017
    skip_before_action :verify_authenticity_token, :only => [:create, :upload_advance_profile_photograph, :upload_advance_profile_identity_proof, :upload_advance_profile_address_proof]
    before_action :set_image, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /images
    def index
      @images = Image.all
      render json: @images
    end
  
    # GET /images/1
    def show
    end
  
    # GET /images/new
    def new
      @image = Image.new
    end
  
    # GET /images/1/edit
    def edit
    end
  
    # POST /images
    def create
      t = Time.now.to_i.to_s
      file = params['file'].tempfile
      s3_bucket = ENV['REGISTRATION_PROFILE_PICTURES_BUCKET']
      file_name = params['file'].original_filename
      s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{params['file'].original_filename}"
      res = self.upload_image(file_name, s3_file_path, file, s3_bucket, true, params[:imageable_id], params[:imageable_type])
      if res
        render json: @image
      else
        render json: {error: 1, message: 'Image could not be saved'}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /images/1
    def update
      if @image.update(image_params)
        render json: @image
      else
        render json: @image.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /images/1
    def destroy
      @img = @image.destroy
      render json: @img
    end
  
    # method to upload advance profile image on s3
    def upload_advance_profile_photograph
      t = Time.now.to_i.to_s
      file = params['file'].tempfile
      s3_bucket = ENV['REGISTRATION_PROFILE_PICTURES_BUCKET']
      file_name = params['file'].original_filename
      s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{params['file'].original_filename}"
      begin
        file = validate_file_type(params[:file], params['file'].original_filename)
        file_name = File.basename(params['file'].original_filename, '.*') + '.png'
        s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{file_name}"
      rescue Exception
      end
      res = self.upload_image(file_name, s3_file_path, file, s3_bucket, true, params[:imageable_id].to_s, params[:imageable_type].to_s)
      begin
        File.delete(file) if File.exist?(file)
      rescue Exception
      end
      if res
        @sadhak_profile = AdvanceProfile.find(params[:imageable_id]).sadhak_profile
        @sadhak_profile.update_attribute('profile_photo_status', 'pp_pending')
        render json: @image
      else
        render json: {error: 1, message: 'Image could not be saved'}, status: :unprocessable_entity
      end
    end
  
    # method to upload advance profile identity proof image on s3
    def upload_advance_profile_identity_proof
      t = Time.now.to_i.to_s
      file = params['file'].tempfile
      s3_bucket = ENV['REGISTRATION_IDENTITY_PROOFS_BUCKET']
      file_name = params['file'].original_filename
      s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{params['file'].original_filename}"
      begin
        file = validate_file_type(params[:file], params['file'].original_filename)
        file_name = File.basename(params['file'].original_filename, '.*') + '.png'
        s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{file_name}"
      rescue Exception
      end
      res = self.upload_image(file_name, s3_file_path, file, s3_bucket, true, params[:imageable_id].to_s, params[:imageable_type].to_s)
      begin
        File.delete(file) if File.exist?(file)
      rescue Exception
      end
      if res
        @sadhak_profile = AdvanceProfile.find(params[:imageable_id]).sadhak_profile
        @sadhak_profile.update_attribute('photo_id_status', 'pi_pending')
        render json: @image
      else
        render json: {error: 1, message: 'Image could not be saved'}, status: :unprocessable_entity
      end
    end
  
    def upload_advance_profile_address_proof
      t = Time.now.to_i.to_s
      file = params['file'].tempfile
      s3_bucket = ENV['REGISTRATION_ADDRESS_PROOFS_BUCKET']
      file_name = params['file'].original_filename
      s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{params['file'].original_filename}"
      begin
       file = validate_file_type(params[:file], params['file'].original_filename)
       file_name = File.basename(params['file'].original_filename, '.*') + '.png'
       s3_file_path = "#{ENV['ENVIRONMENT']}/#{t}-#{file_name}"
      rescue Exception
      end
      res = self.upload_image(file_name, s3_file_path, file, s3_bucket, true, params[:imageable_id].to_s, params[:imageable_type].to_s)
      begin
       File.delete(file) if File.exist?(file)
      rescue Exception
      end
      if res
        @sadhak_profile = AdvanceProfile.find(params[:imageable_id]).sadhak_profile
        @sadhak_profile.update_attribute('address_proof_status', 'ap_pending')
        render json: @image
      else
        render json: {error: 1, message: 'Image could not be saved'}, status: :unprocessable_entity
      end
    end
  
    def upload_ticket_file
      # t = Time.now.to_i.to_s
      # file = params['file'].tempfile
      # s3_bucket = ENV['REGISTRATION_PROFILE_PICTURES_BUCKET']
      # file_name = params['file'].original_filename
      # s3_file_path = t + "-" + params['file'].original_filename
      # res = self.upload_image(file_name, s3_file_path, file, s3_bucket, true, params[:imageable_id].to_s, params[:imageable_type].to_s)
      # if res
      #   render json: @image
      # else
      #   render json: {error: 1, message: "Image could not be saved"}, status: :unprocessable_entity
      # end
  
    end
  
    # method to upload image to s3 and store the image data in db
    def upload_image(file_name, file_path, content, bucket_name, is_secure, imageable_id, imageable_type)
      bucket = Aws::S3::Bucket.new(bucket_name)
      s3_file = bucket.put_object(acl: is_secure ? 'private' : 'public-read', body: content, content_type: MIME::Types.type_for(file_name).first.content_type, key: file_path)
      @image = Image.where(imageable_id: imageable_id, imageable_type: imageable_type).first
        if @image.present?
          @image.update_attributes({:name => file_name, :s3_url => s3_file.public_url.to_s, :s3_path => file_path, :is_secure => is_secure, :s3_bucket => bucket_name})
        else
           @image = Image.new({:name => file_name, :s3_url => s3_file.public_url.to_s, :s3_path => file_path, :is_secure => is_secure, :s3_bucket => bucket_name, :imageable_id => imageable_id, :imageable_type => imageable_type})
      if @image.save(validate: :false)
        return true
      else
        #delete image from aws if image save failed in db
        #s3.bucket(ENV['REGISTRATION_PROFILE_PICTURES_BUCKET']).delete_key(file)
        return false
      end
        end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_image
        @image = Image.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def image_params
        params.require(:image).permit(:name, :imageable_id, :imageable_type)
      end
  end
end
