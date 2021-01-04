module Api::V1
  class EventTypeDigitalAssetAssociationsController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :locate_collection, only: [:index]
    before_action :set_event_type_digital_asset_association, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, only: [:index]
    respond_to :json
  
    # GET /event_type_digital_asset_associations
    def index
      render json: @event_type_digital_asset_associations
    end
  
    # GET /event_type_digital_asset_associations/1
    def show
      authorize @event_type_digital_asset_association
      render json: @event_type_digital_asset_association
    end
  
    # GET /event_type_digital_asset_associations/new
    def new
      @event_type_digital_asset_association = EventTypeDigitalAssetAssociation.new
    end
  
    # GET /event_type_digital_asset_associations/1/edit
    def edit
    end
  
    # POST /event_type_digital_asset_associations
    def create
      @event_type_digital_asset_association = EventTypeDigitalAssetAssociation.new(event_type_digital_asset_association_params)
      authorize @event_type_digital_asset_association
      if @event_type_digital_asset_association.save
        render json: @event_type_digital_asset_association
      else
        render json: @event_type_digital_asset_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_type_digital_asset_associations/1
    def update
      authorize @event_type_digital_asset_association
      if @event_type_digital_asset_association.update(event_type_digital_asset_association_params)
        render json: @event_type_digital_asset_association
      else
        render json: @event_type_digital_asset_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /event_type_digital_asset_associations/1
    def destroy
      authorize @event_type_digital_asset_association
      event_type_digital_asset_association = @event_type_digital_asset_association.destroy
      render json: event_type_digital_asset_association
    end
  
   def locate_collection
      if params.has_key?("filter")
        @event_type_digital_asset_associations = EventTypeDigitalAssetAssociationPolicy::Scope.new(current_user, EventTypeDigitalAssetAssociation.preloaded_data).resolve(filtering_params)
      else
        @event_type_digital_asset_associations = policy_scope(EventTypeDigitalAssetAssociation.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_type_digital_asset_association
        @event_type_digital_asset_association = EventTypeDigitalAssetAssociation.preloaded_data.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_type_digital_asset_association_params
        params.require(:event_type_digital_asset_association).permit(:event_type_id, :digital_asset_id)
      end
  
      def filtering_params
        params.slice(:event_type_id, :digital_asset_id)
      end
  end
end
