module Api::V1
  
  class VimeoController < BaseController
    before_action :authenticate_user!, except: [:view]
  
    def index
      uri = URI.parse('https://api.vimeo.com/me/videos')
      uri.query = URI.encode_www_form(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      request['Authorization'] = "bearer #{ENV['ENVIRONMENT'] == 'testing' ? '91efbcf5d878a11f26fe61fd87397f6c' : Rails.application.secrets.vimeo_token}"
      response = http.request(request)
      render json: response.body
    end
  
    def view
      sadhak_profile = current_user.try(:sadhak_profile)
      sy_club = sadhak_profile.try(:sy_clubs).try(:first)
      show_video_id = (sy_club.present? and (sadhak_profile.try(:active_club_ids) || []).size > 0 and sy_club.has_board_members_paid and sy_club.active_members_count >= sy_club.min_members_count)
  
      if show_video_id || current_user.try(:super_admin?) || current_user.try(:digital_store_admin?) || current_user.try(:club_admin?)
  
        video_id = params[:video_id]
        digital_asset_secret = DigitalAssetSecret.find_by_video_id(video_id)
  
        if digital_asset_secret.present? && digital_asset_secret.digital_asset.present?
  
          render json: {download: [{quality: 'source', size: digital_asset_secret.digital_asset.asset_file_size, link: "http://d3mtufx3ge0c9w.cloudfront.net/#{URI::encode(digital_asset_secret.digital_asset.asset_name)}.mp4"}]}
  
        else
          uri = URI.parse('https://api.vimeo.com/videos/'+video_id)
          uri.query = URI.encode_www_form(params)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          request = Net::HTTP::Get.new(uri.request_uri)
          request['Authorization'] = "bearer #{ENV['ENVIRONMENT'] == 'testing' ? '91efbcf5d878a11f26fe61fd87397f6c' : Rails.application.secrets.vimeo_token}"
          response = http.request(request)
          render json: response.body
        end
      else
        render json: {errors: ['Unauthorized Access.']}
      end
    end
  
  end
end
