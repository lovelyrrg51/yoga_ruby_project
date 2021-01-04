class Chrome::Api::V1::SadhakProfilesController < Chrome::Api::V1::BaseController
	before_action :authenticate_user!
	respond_to :json

	def show
		@sadhak_profile = SadhakProfile.find(params[:id])
		render json: @sadhak_profile, serializer: Chrome::Api::V1::SadhakProfileSessionSerializer, root: 'sadhak_profile'
	end

end