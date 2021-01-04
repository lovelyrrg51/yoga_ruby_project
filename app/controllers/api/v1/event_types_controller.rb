module Api::V1
  class EventTypesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :wp_event_types]
    before_action :set_event_type, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index, :wp_event_types]
    respond_to :json
  
    # GET /event_types
    def index
      if params.has_key?('mode') and params[:mode] == 'club_activity_types'
        @club_activity_types = EventType.includes(:event_type_digital_asset_associations, :digital_assets, :event_type_pricings).where(is_club_activity: true)
        render json: @club_activity_types
      else
        @event_types = policy_scope(EventType).includes(:event_type_digital_asset_associations, :digital_assets, :event_type_pricings)
        render json: @event_types
      end
    end
  
    # GET /wp_event_types
    def wp_event_types
      render json: EventType.order(:id).all, each_serializer: WpEventTypeSerializer
    end
  
    # GET /event_types/1
    def show
      render json: @event_type
    end
  
    # GET /event_types/new
    def new
      @event_type = EventType.new
    end
  
    # GET /event_types/1/edit
    def edit
    end
  
    # POST /event_types
    def create
      @event_type = EventType.new(event_type_params)
      authorize @event_type
      if @event_type.save
        render json: @event_type
      else
        render json: @event_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_types/1
    def update
      authorize @event_type
      if @event_type.update(event_type_params)
        render json: @event_type
      else
        render json: @event_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_types/1
    def destroy
      authorize @event_type
      res = @event_type.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_type
        @event_type = EventType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_type_params
        params.require(:event_type).permit(:name, :event_meta_type, :is_club_activity, :feedback_form, :reference_event_id)
      end
  end
end
