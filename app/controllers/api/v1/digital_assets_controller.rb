module Api::V1
  class DigitalAssetsController < BaseController
    before_action :authenticate_user!, :except => [:index, :show, :search, :test, :wp_digital_assets, :view]
    before_action :locate_collection, :only => :index
    before_action :set_digital_asset, only: [:show, :edit, :update, :destroy, :download]
    skip_before_action :verify_authenticity_token, only: [:wp_digital_assets]
    respond_to :json
  
    # GET /digital_assets
    def index
      sadhak_profile = current_user.try(:sadhak_profile)
      sy_club = sadhak_profile.try(:sy_clubs).try(:first) || sadhak_profile.try(:advisory_counsil).try(:sy_club)

      # Check is_valid_board_member?
      is_valid_board_member = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)

      # Check can_view_shivir_collection?
      can_view_shivir_collection = sadhak_profile.can_view_shivir_collection

      show_video_id = true

      unless current_user.present? && (current_user.super_admin? || current_user.digital_store_admin? || current_user.club_admin?)
        
        if is_valid_board_member && can_view_shivir_collection
          @digital_assets = @digital_assets.select{ |asset| asset.collection.forum? } + sadhak_profile.accessable_shivir_episodes
        elsif is_valid_board_member
          @digital_assets = @digital_assets.select{ |asset| asset.collection.forum? }
        elsif can_view_shivir_collection
          @digital_assets = sadhak_profile.accessable_shivir_episodes
        else
          show_video_id, @digital_assets = false, []
        end

        accessible_shivir_type_episodes = sadhak_profile.accessible_shivir_type_episodes
        @digital_assets = @digital_assets + accessible_shivir_type_episodes if accessible_shivir_type_episodes.present?
      end
      

      @digital_assets = @digital_assets.uniq
      @digital_assets.map {|asset|
        show_video_id ||= DigitalAssetPolicy.new(current_user, asset).show_video_id?
        if show_video_id
          digital_asset_secret = asset.digital_asset_secret
          asset.video_id = digital_asset_secret.try(:video_id).to_s
          asset.asset_file_size = digital_asset_secret.try(:asset_file_size)
          asset.asset_url = (current_user.present? && (current_user.super_admin? || current_user.digital_store_admin? || current_user.club_admin?)) ? digital_asset_secret.try(:asset_url) : ''
        else
          asset.video_id = ''
          asset.asset_file_size = 0
          asset.asset_url = ''
        end
        asset.is_owned = show_video_id
      }
      render json: @digital_assets, serializer: PaginationSerializer, root: 'digital_assets', adapter: :json
    end
  
    def wp_digital_assets
      
      begin
  
        sadhak_profile = current_user.try(:sadhak_profile)
  
        sy_club = sadhak_profile.try(:sy_clubs).try(:first)
  
        show_video_id = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)
  
        language = sy_club.try(:content_type).to_s.split(',')
  
        language = (language.kind_of?(Array) ? language : [language]).map(&:downcase)
  
        params[:sort] = 'published_on' unless params[:sort].present?
  
        year = Time.zone.now.to_date.year
  
        year = year - 1 if Time.zone.now.to_date.month < 8
  
        from_date = Date.new(year, 8, 1) # Aug 01, YYYY
  
        query_input = {from_date: from_date, to_date: Time.zone.now.to_date, language: language}
  
        @digital_assets = DigitalAsset.where('published_on >= :from_date AND published_on <= :to_date AND LOWER(language) IN (:language)', query_input).order(ordering_params(params)).select{|da| show_video_id || DigitalAssetPolicy.new(current_user, da).show_video_id? }
  
      rescue Exception => e
        message = e.message
      end
  
      unless message.present?
        render json: @digital_assets, each_serializer: WpDigitalAssetSerializer
      else
        render json: {errors: [message]}, status: :unprocessable_entity
      end
  
    end
  
    # GET /digital_assets/1
    def show
      @digital_asset = DigitalAsset.find(params[:id]);
      if params.has_key?("source")
  
        if @digital_asset.collection_id != nil
          @collection = Collection.find_by_id(@digital_asset.collection_id)
          @source_asset = DigitalAsset.find(@collection.source_asset_id);
          render json: @source_asset
        else
          render json: nil
        end
      else
        if current_user.nil? or current_user.digital_assets.find_by(id: params[:id]) == nil
          show_video_id = DigitalAssetPolicy.new(current_user, @digital_asset).show_video_id?
          if !show_video_id
            @digital_asset.video_id = ""
            # @digital_asset.digital_asset_secret_id = ""
          end
          # @digital_asset.video_id = ""
        end
        render json: @digital_asset
      end
    end
  
    # GET /digital_assets/new
    def new
      @digital_asset = DigitalAsset.new
    end
  
    # GET /digital_assets/1/edit
    def edit
    end
  
    # POST /digital_assets
    def create
      @digital_asset = DigitalAsset.new(digital_asset_params)
      authorize @digital_asset
      begin
        if params.has_key?('file') and params[:file].present?
          file = params[:file]
          original_filename = params['file'].original_filename
          content = file.tempfile.path
          time_stamp = Time.now.to_i.to_s
          params[:digital_asset][:asset_content_type] = file.content_type
          s3_file_path = ENV['ENVIRONMENT'] + '/' + time_stamp + '-' + original_filename
          bucket = Aws::S3::Bucket.new(ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET'])
          raise RuntimeError.new('No bucket found.') unless bucket.exists?
          s3_file = bucket.put_object(acl: 'private', body: content, content_type: MIME::Types.type_for(original_filename).first.content_type, key: s3_file_path)
          raise RuntimeError.new('Something went wrong while uploading asset. Please try again.') unless s3_file.exists?
  
          # Generate a digital asset secret for uploaded asset
          ActiveRecord::Base.transaction do
            digital_asset_secret = DigitalAssetSecret.create(asset_file_name: original_filename, asset_url: s3_file.key)
            raise RuntimeError.new(digital_asset_secret.errors.to_a.first) unless digital_asset_secret.errors.empty?
            @digital_asset = digital_asset_secret.create_digital_asset(digital_asset_params)
            raise RuntimeError.new(@digital_asset.errors.to_a.first) unless @digital_asset.errors.empty?
          end
        else
          # raise RuntimeError.new("File not found. Please provide a file to upload.")
        end
      rescue Aws::S3::Errors::ServiceError => e
        logger.info(e.message)
        message = e.message
      rescue Exception => e
        logger.info(e.message)
        message = e.message
      end
      if message.nil?
        if @digital_asset.save
          render json: @digital_asset
        else
          render json: @digital_asset.errors.as_json(full_messages: true), status: :unprocessable_entity
        end
      else
        render json: {message: [message]}, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /digital_assets/1
    def update
      unless DigitalAssetPolicy.new(current_user, nil).update?
        render json: {error: 'Unauthorized access.', status: 403}, status: 403
      else
        if @digital_asset.update(digital_asset_params)
          render json: @digital_asset
        else
          render json: @digital_asset.errors, status: :unprocessable_entity
        end
      end
    end
  
    # DELETE /digital_assets/1
    def destroy
      unless DigitalAssetPolicy.new(current_user, nil).destroy?
        render json: {error: 'Unauthorized access.', status: 403}, status: 403
      else
        res = @digital_asset.destroy
        render json: res
      end
    end
  
    # GET /digital_assets/1/download
    def download
      authorize @digital_asset
      download_url, message = @digital_asset.s3_downloadable_url(ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET'])
      if message.present?
        render json: {message: [message]}, status: :unprocessable_entity
      else
        # for local files
        # send_file '/path/to/file', :type => 'image/jpeg', :disposition => 'attachment'
        digital_asset_secret = @digital_asset.digital_asset_secret
        asset_url = digital_asset_secret.asset_url
        content_type = asset_url.present? ? asset_url[asset_url.rindex(".")..asset_url.length] : ""
        # for remote files
        # https://gist.github.com/maxivak/4430975
        require 'open-uri'
        data = open(download_url).read
        send_data data, type: @digital_asset.asset_content_type.to_s, disposition: 'attachment', filename: "#{Time.now.to_i}#{content_type}"
        render json: {message: ["Asset is downloading please wait..."]}
      end
    end
  
    def test
      # the_url = 'http://player.vimeo.com/external/106073001.sd.mp4?s=d530196875e3d45cf3ca434c9c89db78'
      the_url = 'https://player.vimeo.com/video/106073001'
      uri = URI.parse(the_url)
      redirect_to uri.to_s
      rescue URI::InvalidURIError => encoding
      redirect_to URI.encode(the_url)
      redirect_to 'player.vimeo.com/video/106073001'
    end
  
    def view
      begin
  
        raise 'Video id cannot be blank.' unless params[:video_id].present?
  
        sadhak_profile = current_user.try(:sadhak_profile)
  
        sy_club = sadhak_profile.try(:sy_clubs).try(:first) || sadhak_profile.try(:advisory_counsil).try(:sy_club)
  
        show_video_id = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)

        show_video_id ||= sadhak_profile.can_view_shivir_collection
    
        raise 'Unauthorized Access.' unless show_video_id || current_user.try(:super_admin?) || current_user.try(:digital_store_admin?) || current_user.try(:club_admin?)
  
        digital_asset_secret = DigitalAssetSecret.find_by_video_id(params[:video_id])
  
        raise 'Digital asset not found.' unless digital_asset_secret.present?
  
        result = {download: [{quality: 'source', size: digital_asset_secret.asset_file_size, link: digital_asset_secret.asset_url}]}
  
      rescue Exception => e
        message = e.message
      end
  
      if message.present?
        render json: {errors: [message]}, status: :unprocessable_entity
      else
        render json: result
      end
  
    end
  
    private
    # Use callbacks to share common setup or constraints between actions.
    def set_digital_asset
      @digital_asset = DigitalAsset.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def digital_asset_params
      params.require(:digital_asset).permit(:asset_name, :available_for, :author, :tag, :expires_at, :published_on, :asset_url, :collection_id, :language)
    end
  
    def locate_collection
      if params[:page].present?
        @digital_assets = DigitalAssetPolicy::Scope.new(current_user, DigitalAsset).resolve(filtering_params).includes(DigitalAsset.includable_data).page(params[:page]).per(params[:per_page])
      else
        @digital_assets = DigitalAssetPolicy::Scope.new(current_user, DigitalAsset).resolve(filtering_params).includes(DigitalAsset.includable_data)
      end
    end
    def filtering_params
      params.slice(:author, :tag, :event_type_id, :event_types)
    end
  
  end
end
