module Api::V1
  class DsProductAssetTagAssociationsController < BaseController
    before_action :authenticate_user
    before_action :set_ds_product_asset_tag_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ds_product_asset_tag_associations
    def index
      @ds_product_asset_tag_associations = DsProductAssetTagAssociation.all
      render json: @ds_product_asset_tag_associations
    end
  
    # GET /ds_product_asset_tag_associations/1
    def show
    end
  
    # GET /ds_product_asset_tag_associations/new
    def new
      @ds_product_asset_tag_association = DsProductAssetTagAssociation.new
    end
  
    # GET /ds_product_asset_tag_associations/1/edit
    def edit
    end
  
    # POST /ds_product_asset_tag_associations
    def create
      @ds_product_asset_tag_association = DsProductAssetTagAssociation.new(ds_product_asset_tag_association_params)
      if @ds_product_asset_tag_association.save
        render json: @ds_product_asset_tag_association
      else
        render json: @ds_product_asset_tag_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ds_product_asset_tag_associations/1
    def update
      if @ds_product_asset_tag_association.update(ds_product_asset_tag_association_params)
        render json: @ds_product_asset_tag_association
      else
        render json: @ds_product_asset_tag_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ds_product_asset_tag_associations/1
    def destroy
      dpa = @ds_product_asset_tag_association.destroy
      render json: dpa
  
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ds_product_asset_tag_association
        @ds_product_asset_tag_association = DsProductAssetTagAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ds_product_asset_tag_association_params
        params.require(:ds_product_asset_tag_association).permit(:ds_product_id, :ds_asset_tag_id)
      end
  end
end
