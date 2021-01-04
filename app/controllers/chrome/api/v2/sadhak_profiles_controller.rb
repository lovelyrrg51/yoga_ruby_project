class Chrome::Api::V2::SadhakProfilesController < Chrome::Api::V2::BaseController

	def send_report
		begin
			current_user.send_extension_asset_report(report_params)
		rescue Exception => e
			@message = e.message
		ensure
            if @message.present?
                render json: @error_msg, status: :unauthorized
            else
                render json: {}, status: 200
            end
		end
	end

	def update_downloaded_assets
		begin

			raise "No User found." unless current_user.present? && sadhak_profile = current_user.try(:sadhak_profile)

			raise "No Downloaded Assets found." unless downloaded_assets = params[:downloadedAssets]

			downloaded_assets = downloaded_assets.try(:split, ",")

			if sadhak_profile.extension_detail.present?
				sadhak_profile.extension_detail.update!({ downloaded_assets: downloaded_assets })
			else
				sadhak_profile.build_extension_detail({ downloaded_assets: downloaded_assets })
				sadhak_profile.extension_detail.save!
			end

			render json: {}, status: 200
		rescue Exception => e
			render json: { msg: e.message }, status: :unauthorized
		end
	end

	private
	
	def report_params
		params.permit(:sy_club_id, :content, :asset_id)
	end
end