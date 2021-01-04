class Chrome::Api::V1::DigitalAssetsController < Chrome::Api::V1::BaseController

  before_action :authenticate_user!, :except => []
  respond_to :json

  def forum_digital_assets

    is_admin = current_user.super_admin? or current_user.digital_store_admin? or current_user.club_admin?

    if show_video_id = is_admin
       @digital_assets = DigitalAsset.includes(:digital_asset_secret)
    else
      sadhak_profile = current_user.try(:sadhak_profile)
      sy_club = sadhak_profile.try(:sy_clubs).try(:first)
      show_video_id = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)
      language = sy_club.try(:content_type).to_s.split(',')
      @digital_assets = DigitalAsset.filter({published_on: Date.today.to_s, expires_at: Date.today.to_s, language: language}).includes(:digital_asset_secret)
    end

    @digital_assets = @digital_assets.page(params[:page]).per(params[:per_page]) if params[:page].present?

    @digital_assets.map { |asset|
      
      if show_video_id
        digital_asset_secret = asset.digital_asset_secret
        asset.video_id = digital_asset_secret.try(:video_id).to_s
        asset.asset_file_size = digital_asset_secret.try(:asset_file_size)
        asset.asset_url = (current_user.present? && (current_user.super_admin? || current_user.digital_store_admin? || current_user.club_admin?)) ? digital_asset_secret.try(:asset_url) : ''
      else
        asset.video_id = ''
        asset.asset_file_size = 0
      end

      asset.is_owned = show_video_id

    }

    render json: @digital_assets, serializer: PaginationSerializer, each_serializer: Chrome::Api::V1::ForumDigitalAssetSerializer

  end

  def virtual_shivir_digital_assets

    begin
     sadhak_profile = current_user.try(:sadhak_profile)

     @digital_assets = sadhak_profile.events.joins({ event_type: [:digital_assets] }).where("Date(?) BETWEEN event_start_date - interval '2 day' AND event_end_date + interval '1 day'",Time.now.to_date).where(event_types: { event_meta_type: EventType.event_meta_types[:virtual] }).select('digital_assets.*')

     @digital_assets = @digital_assets.page(params[:page]).per(params[:per_page]) if params[:page].present?

    rescue Exception => e
      message = e.message
    end

    unless message.present?
      render json: @digital_assets, each_serializer: Chrome::Api::V1::VirtualShivirDigitalAssetSerializer, serializer: PaginationSerializer
    else
      render json: { errors: [message] }, status: :unprocessable_entity
    end
  end

end