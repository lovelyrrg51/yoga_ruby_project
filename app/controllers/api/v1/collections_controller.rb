module Api::V1
  class CollectionsController < BaseController
    before_action :authenticate_user!, :except => [:index, :show]
    respond_to :json
  
    def index
      @collections = Collection.includes(:digital_assets).all
      render json: @collections, root: 'collections', adapter: :json
    end
  
    def show
      @collection = Collection.find(params[:id])
      render json: @collection
    end
  
    def new
      @collection = Collection.new
    end
  
    def edit
      @collection = Collection.find(params[:id])
      @collection.update(collection_parms)
    end
  
    def create
      @collection = Collection.new(collection_params)
  
      if @collection.save
        render json: @collection
      else
        render json: @collection.errors, status: :unprocessable_entity
      end
    end
  
    def update
      @collection = Collection.find(params[:id])
      if @collection.update(collection_params)
        render json: @collection
      else
        render json: @collection.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /digital_assets/1
    # DELETE /digital_assets/1.json
    def destroy
      @collection = Collection.find(params[:id])
      res = @collection.destroy
      render json: res
  
    end
  
    private
  
      # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:source_asset_id, :collection_name, :collection_description)
    end
  
  end
end
