module Api::V1
  class DsAssetTagsController < BaseController
    before_action :authenticate_user!
    before_action :set_ds_asset_tag, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /ds_asset_tags
    def index
      @ds_asset_tags = DsAssetTag.all
      render json: @ds_asset_tags
    end
  
    # GET /ds_asset_tags/1
    def show
    end
  
    # GET /ds_asset_tags/new
    def new
      @ds_asset_tag = DsAssetTag.new
    end
  
    # GET /ds_asset_tags/1/edit
    def edit
    end
  
    # POST /ds_asset_tags
    def create
      @ds_asset_tag = DsAssetTag.new(ds_asset_tag_params)
      if @ds_asset_tag.save
        render json: @ds_asset_tag
      else
        render json: @ds_asset_tag.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_asset_tags/1
    def update
      if @ds_asset_tag.update(ds_asset_tag_params)
        render json: @ds_asset_tag
      else
        render json: @ds_asset_tag.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_asset_tags/1
    def destroy
      dst = @ds_asset_tag.destroy
      render json: dst
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_asset_tag
        @ds_asset_tag = DsAssetTag.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_asset_tag_params
        params.require(:ds_asset_tag).permit(:name)
      end
  end
end
