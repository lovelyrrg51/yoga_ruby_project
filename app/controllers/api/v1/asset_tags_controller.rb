module Api::V1
  class AssetTagsController < BaseController
    before_action :authenticate_user!, :except => [:index, :show]
    respond_to :json
  
    def index
      @asset_tags = AssetTag.all
      render json: @asset_tags
    end
  
    def show
      @asset_tag = AssetTag.find(params[:id])
      render json: @asset_tag
    end
  
    def new
      @asset_tag = AssetTag.new
    end
  
    def edit
      @asset_tag = AssetTag.find(params[:id])
      @asset_tag.update(asset_tag_parms)
    end
  
    def create
      @asset_tag = AssetTag.new(asset_tag_params)
  
      if @asset_tag.save
        render json: @asset_tag
      else
        render json: @asset_tag.errors, status: :unprocessable_entity
      end
    end
  
    def update
      @asset_tag = AssetTag.find(params[:id])
      if @asset_tag.update(asset_tag_params)
        render json: @asset_tag
      else
        render json: @asset_tag.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /digital_assets/1
    # DELETE /digital_assets/1.json
    def destroy
      @asset_tag = AssetTag.find(params[:id])
      @asset_tag.destroy
      render json: {}
  
    end
  
    private
  
      # Never trust parameters from the scary internet, only allow the white list through.
    def asset_tag_params
      params.require(:asset_tag).permit(:tag, :tag_priority, :tag_collection_id, :thumbnail_url, :thumbnail_path)
    end
  
  end
end
