class Chrome::Api::V1::SyClubsController < Chrome::Api::V1::BaseController
	before_action :authenticate_user!
	respond_to :json

	def show
		@sy_club = SyClub.find(params[:id])
		render json: @sy_club, serializer: Chrome::Api::V1::SyClubSerializer
	end

end