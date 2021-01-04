module Api::V1
  class DsAssetTagCollectionsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_asset_tag_collection, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_asset_tag_collections
    def index
      @ds_asset_tag_collections = DsAssetTagCollection.all
      render json:  @ds_asset_tag_collections
    end
  
    # GET /ds_asset_tag_collections/1
    def show
    end
  
    # GET /ds_asset_tag_collections/new
    def new
      @ds_asset_tag_collection = DsAssetTagCollection.new
    end
  
    # GET /ds_asset_tag_collections/1/edit
    def edit
    end
  
    # POST /ds_asset_tag_collections
    def create
      @ds_asset_tag_collection = DsAssetTagCollection.new(ds_asset_tag_collection_params)
      if @ds_asset_tag_collection.save
        render json:  @ds_asset_tag_collection
      else
        render json: @ds_asset_tag_collection.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_asset_tag_collections/1
    def update
      if @ds_asset_tag_collection.update(ds_asset_tag_collection_params)
        render json:  @ds_asset_tag_collection
      else
        render json: @ds_asset_tag_collection.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_asset_tag_collections/1
    def destroy
      ds_tg_c = @ds_asset_tag_collection.destroy
      render json:  ds_tg_c
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_asset_tag_collection
        @ds_asset_tag_collection = DsAssetTagCollection.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_asset_tag_collection_params
        params.require(:ds_asset_tag_collection).permit(:name, :ds_asset_tag_id)
      end
  end
end
