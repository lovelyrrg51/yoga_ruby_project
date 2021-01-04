module Api::V1
  class DigitalAssetSecretsController < BaseController
    before_action :authenticate_user!, except: [:show, :index]
    before_action :set_digital_asset_secret, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /digital_asset_secrets/1
    # GET /digital_asset_secrets/1.json
    def show
      @digital_asset = @digital_asset_secret.digital_asset
      show_secret_data = DigitalAssetSecretPolicy.new(current_user, @digital_asset).show_secret_data?
      if !show_secret_data
        @digital_asset_secret.video_id = nil
        @digital_asset_secret.embed_code = nil
        @digital_asset_secret.asset_dl_url = nil
      elsif @digital_asset.asset_type = "s3_audio"
        bucket = Aws::S3::Bucket.new(ENV['SYPORTAL_AUDIO_BUCKET'])
        object = bucket.object(@digital_asset_secret.asset_file_name)
        @digital_asset_secret.asset_dl_url = object.presigned_url(:get, expires_in: 7200, virtual_host: true).to_s
      end
      render json: @digital_asset_secret
    end
  
    def index
      @digital_asset_secrets = DigitalAssetSecret.includes(:digital_asset).all
      show_secret_data = DigitalAssetSecretPolicy.new(current_user, nil).show_all_secrets?
      bucket = Aws::S3::Bucket.new(ENV['SYPORTAL_AUDIO_BUCKET'])
  
  
      if !show_secret_data
        @digital_asset_secrets = []
      else
        @digital_asset_secrets.map {|das|
          if das.digital_asset and das.digital_asset.asset_type = 's3_audio'
            object = bucket.object(das.asset_file_name)
            das.asset_dl_url = object.presigned_url(:get, expires_in: 7200, virtual_host: true).to_s
          end
        }
      end
      render json: @digital_asset_secrets
    end
  
    def create
      @digital_asset_secret = DigitalAssetSecret.new(digital_asset_secret_params)
      if !(DigitalAssetSecretPolicy.new(current_user, nil).create?)
        render json: { error: "Unauthorized access.", status: 403 }, status: 403
        return false
      end
      params.each do |p|
        logger.info p
      end
        if @digital_asset_secret.save
          render json: @digital_asset_secret
        else
          render json: @digital_asset_secret.errors, status: :unprocessable_entity
        end
    end
  
    def edit
  
    end
  
    def update
      authorize @digital_asset_secret
      if @digital_asset_secret.update(digital_asset_secret_params)
        render json: @digital_asset_secret
      else
        render json: @digital_asset_secret.errors, status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
    def set_digital_asset_secret
      @digital_asset_secret = DigitalAssetSecret.find(params[:id])
    end
  
    def digital_asset_secret_params
      params.require(:digital_asset_secret).permit!
    end
  
  end
end
