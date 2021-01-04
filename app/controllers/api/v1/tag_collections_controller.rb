module Api::V1
  class TagCollectionsController < BaseController
    before_action :authenticate_user!, :except => [:index, :show]
    respond_to :json
  
    def index
      @tag_collection = TagCollection.all
      render json: @tag_collection
    end
  
    def show
      @tag_collection = TagCollection.find(params[:id])
      render json: @tag_collection
    end
  
    def new
      @tag_collection = TagCollection.new
    end
  
    def edit
      @tag_collection = TagCollection.find(params[:id])
      @tag_collection.update(tag_collection_params)
    end
  
    def create
      @tag_collection = TagCollection.new(tag_collection_params)
  
      if @tag_collection.save
        render json: @tag_collection
      else
        render json: @tag_collection.errors, status: :unprocessable_entity
      end
    end
  
    def update
     @tag_collection = TagCollection.find(params[:id])
  
      if @tag_collection.update(tag_collection_params)
        render json: @tag_collection
      else
        render json: @tag_collection.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /tag_collections/1
    # DELETE /tag_collections/1.json
    def destroy
      @tag_collection = TagCollection.find(params[:id])
      @tag_collection.destroy
      render json: {}
  
    end
  
    private
  
      # Never trust parameters from the scary internet, only allow the white list through.
    def tag_collection_params
      params.require(:tag_collection).permit(:name, :priority, :menu_id)
    end
  end
end
