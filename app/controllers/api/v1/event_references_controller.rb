module Api::V1
  class EventReferencesController < BaseController
    before_action :authenticate_user!
    before_action :locate_collection, :only => :index
    before_action :set_event_reference, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_references
    def index
      render json:  @event_references
    end
  
    # GET /event_references/1
    def show
    end
  
    # GET /event_references/new
    def new
      @event_reference = EventReference.new
    end
  
    # GET /event_references/1/edit
    def edit
    end
  
    # POST /event_references
    def create
      @event_reference = EventReference.new(event_reference_params)
  #     authorize  @event_reference
      if @event_reference.save
        render json:  @event_reference
      else
        render json: @event_reference.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_references/1
    def update
      authorize  @event_reference
      if @event_reference.update(event_reference_params)
        render json:  @event_reference
      else
        render json: @event_reference.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_references/1
    def destroy
      authorize  @event_reference
      er = @event_reference.destroy
      render json: er
    end
  
    def locate_collection
      if (params.has_key?("filter"))
        @event_references = EventReferencePolicy::Scope.new(current_user, EventReference).resolve(filtering_params)
      else
        @event_references = policy_scope(EventReference)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_reference
        @event_reference = EventReference.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_reference_params
        params.require(:event_reference).permit(:sadhak_profile_id, :event_id)
      end
      def filtering_params
        params.slice(:event_id)
      end
  end
end
