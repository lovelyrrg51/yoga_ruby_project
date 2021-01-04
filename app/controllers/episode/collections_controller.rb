class Episode::CollectionsController < ApplicationController

	before_action :find_collection, only: [:edit, :update, :destroy]
	before_action :locate_collection, only: [:edit, :index]
	before_action :authenticate_user!

    def index
    	authorize(:collection, :index?)
    	@collection = Collection.new
    end

    def create
    		collection =  Collection.new(collection_params)
    	authorize collection
    	if collection.save
    		flash[:success] = "Collection has been successfully created."
    	else
    		flash[:error] = collection.errors.full_messages.first
    	end
    	redirect_to collections_path
    end

    def update
    	authorize @collection
    	if @collection.update(collection_params)
    		flash[:success] = "Collection has been successfully updated."
    	else
    		flash[:error] = @collection.errors.full_messages.first
    	end
    	redirect_to collections_path
    end

    def edit
    	authorize @collection
    end

    def destroy
    	authorize @collection
    	if @collection.destroy
    		flash[:success] = "Collection has been successfully deleted."
    	else
    		flash[:error] = @collection.errors.full_messages.first
    	end
    	redirect_back(fallback_location: proc { collections_path })
    end


    private
    def find_collection
    	@collection = Collection.find_by_id(params[:id])
    end

    def locate_collection
    	@collections = CollectionPolicy::Scope.new(current_user, Collection).resolve(filtering_params).page(params[:page]).per(params[:per_page]).includes(:digital_assets)
    end

    def collection_params
    	params.require(:collection).permit(:collection_name, :collection_description)
    end

    def filtering_params
    	 params.slice(:collection_name, :id)
    end
end