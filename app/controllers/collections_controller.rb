class CollectionsController < ApplicationController

	before_action :find_collection, only: [:update_sadhak_asset_access, :edit, :update, :destroy, :edit_episodes_collection, :update_episodes_collection, :destroy_episodes_collection, :update_assets_order]
	before_action :locate_collection, only: [:edit, :index, :episodes_collections, :shivir_collections]
  before_action :authenticate_user!

  def index
  	authorize(:collection, :index?)
  	@collection = Collection.new
    @collections = @collections.forum
  end

  def create
    create_collection
  	redirect_to collections_path
  end

  def update
    update_collection
  	redirect_to collections_path
  end

  def edit
  	authorize @collection
  end

  def destroy
    destroy_collection
  	redirect_back(fallback_location: proc { collections_path })
  end

  def episodes_collections
    authorize(:collection, :shivir_episode_upload_access?)
    @collections = @collections.farmer
  end

  def new_episodes_collection
    authorize(:collection, :shivir_episode_upload_access?)
    begin
      @collection = Collection.new(collection_type: 1)
      @episodes = @collection.episodes.build
    rescue Exception => e
      # redirect back routes or root
    end
  end

  def create_episodes_collection
    create_collection
    if(@collection.errors.present?)
      redirect_back(fallback_location: new_episodes_collection_collections_path)
    else
      redirect_to collection_edit_episodes_collection_path(@collection)
    end
  end

  def update_episodes_collection
    update_collection
    redirect_to collection_edit_episodes_collection_path(@collection)
  end

  def edit_episodes_collection
    authorize(:collection, :shivir_episode_upload_access?)
    @episodes = @collection.episodes.present? ? @collection.episodes : @collection.episodes.build
    if @collection.shivir?
      @collection.build_collection_event_type_association unless @collection.collection_event_type_association.present?
      @event_types = EventType.all
    end
  end

  def destroy_episodes_collection
    authorize(:collection, :shivir_episode_upload_access?)
    destroy_collection
    redirect_to @collection.shivir? ? shivir_collections_collections_path : episodes_collections_collections_path(:collection_type => 'Farmer')
  end

  def update_sadhak_asset_access
    authorize(:collection, :is_shivir_episode_access_admin?)
    if@collection.update_attributes(sadhak_asset_access_params)
      flash[:success] = "Access has been updated."
    else
      flash[:error] = "Error occured on updating access"
    end
    redirect_back(fallback_location: shivir_episode_access_collections_path)
  end

  def shivir_episode_access
    authorize(:collection, :is_shivir_episode_access_admin?)
    # @farmer_episodes = DigitalAsset.joins(:collection).where(collections: { collection_type: 'farmer'})
    @live_episode_collections = Collection.farmer.joins(:digital_assets).where("digital_assets.published_on <= :current_date AND digital_assets.expires_at >= :current_date", {current_date: Date.today}).uniq
    @live_episode_collections.map { |collection| collection.sadhak_asset_access_associations.build unless collection.sadhak_asset_access_associations.present? }
  end


  # Action for collection_type == "shivir"

  def shivir_collections
    authorize(:collection, :shivir_collections?)
    @collections = @collections.shivir
  end

  def new_shivir_collections
    authorize(:collection, :shivir_collections?)
    begin
      @collection = Collection.new(collection_type: Collection.collection_types[:shivir])
      @episodes = @collection.episodes.build
      @collection.build_collection_event_type_association
      @event_types = EventType.all || []
    rescue Exception => e
      flash[:error] = e.message
      redirect_to shivir_collections_collections_path
    end
  end

  def shivir_collections_access
    authorize(:collection, :shivir_collections?)
    @collection_event_type_associations = CollectionEventTypeAssociation.joins(:collection).where(collections: { collection_type: Collection.collection_types[:shivir] })
  end

  def update_assets_order
    begin
      @collection.update_assets_order(assets_order_params)
      is_error = @collection.errors.full_messages.first
      raise SyException, is_error  if is_error
    rescue SyException => e
      @message = e.message
    end
  end

  private

  def create_collection
    @collection =  Collection.new(collection_params)
    authorize(:collection, :shivir_episode_upload_access?)
    if @collection.save
      flash[:success] = "Collection has been successfully created."
    else
      flash[:error] = @collection.errors.full_messages.first
    end
    @collection
  end

  def update_collection
    authorize(:collection, :shivir_episode_upload_access?)
    if @collection.update(collection_params)
      flash[:success] = "Collection has been successfully updated."
    else
      flash[:error] = @collection.errors.full_messages.first
    end
  end

  def destroy_collection
    authorize(:collection, :shivir_episode_upload_access?)
    if @collection.destroy
      flash[:success] = "Collection has been successfully deleted."
    else
      flash[:error] = @collection.errors.full_messages.first
    end
  end

  def find_collection
  	@collection = Collection.find(params[:id] || params[:collection_id])
  end

  def locate_collection
  	@collections = CollectionPolicy::Scope.new(current_user, Collection).resolve(filtering_params).page(params[:page]).per(params[:per_page]).includes(:digital_assets)
  end

  def collection_params
    if params[:collection] && params[:collection][:collection_type] && params[:collection][:collection_type] == "shivir"
      _params = params.require(:collection).permit(:id, :collection_name, :collection_description, :announcement_text, :collection_type, episodes_attributes: [:id, :asset_name, :asset_url, :language, :published_on, :expires_at, :asset_description, :event_type_ids, :_destroy], collection_event_type_association_attributes: [:id, :collection_id, :event_type_id])
    else 
      _params = params.require(:collection).permit(:id, :collection_name, :collection_description, :announcement_text, :collection_type, episodes_attributes: [:id, :asset_name, :asset_url, :language, :published_on, :expires_at, :asset_description, :event_type_ids, :_destroy])
    end
    announcement_text_array.present? ? _params.merge!({ announcement_text: announcement_text_array }) : _params
  end

  def filtering_params
  	 params.slice(:collection_name, :id, :collection_type)
  end
  def sadhak_asset_access_params
    params.require(:collection).permit(:id, sadhak_asset_access_associations_attributes:[:id, :sadhak_profile_ids, :access_from_date, :access_to_date, :_destroy])
  end

  def assets_order_params
    params.require(:assets_order).values.reduce({}, :merge)
  end

  def announcement_text_array
    params[:announcement_text].reject(&:blank?) if params[:announcement_text].present?
  end

end
