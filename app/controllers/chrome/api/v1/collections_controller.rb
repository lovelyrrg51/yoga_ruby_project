class Chrome::Api::V1::CollectionsController < Chrome::Api::V1::BaseController

  respond_to :json

	def index
		@collections = Collection.includes(:digital_assets).all
		render json: @collections
	end

end
