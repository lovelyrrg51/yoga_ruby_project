module Api::V1
  class EventPrerequisitesEventTypesController < BaseController
    before_action :set_event_prerequisites_event_type, only: [:show, :edit, :update, :destroy]
  
    # GET /event_prerequisites_event_types
    # GET /event_prerequisites_event_types.json
    def index
      @event_prerequisites_event_types = EventPrerequisitesEventType.all
    end
  
    # GET /event_prerequisites_event_types/1
    # GET /event_prerequisites_event_types/1.json
    def show
    end
  
    # GET /event_prerequisites_event_types/new
    def new
      @event_prerequisites_event_type = EventPrerequisitesEventType.new
    end
  
    # GET /event_prerequisites_event_types/1/edit
    def edit
    end
  
    # POST /event_prerequisites_event_types
    # POST /event_prerequisites_event_types.json
    def create
      @event_prerequisites_event_type = EventPrerequisitesEventType.new(event_prerequisites_event_type_params)
  
      respond_to do |format|
        if @event_prerequisites_event_type.save
          format.html { redirect_to @event_prerequisites_event_type, notice: 'Event prerequisites event type was successfully created.' }
          format.json { render :show, status: :created, location: @event_prerequisites_event_type }
        else
          format.html { render :new }
          format.json { render json: @event_prerequisites_event_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PATCH/PUT /event_prerequisites_event_types/1
    # PATCH/PUT /event_prerequisites_event_types/1.json
    def update
      respond_to do |format|
        if @event_prerequisites_event_type.update(event_prerequisites_event_type_params)
          format.html { redirect_to @event_prerequisites_event_type, notice: 'Event prerequisites event type was successfully updated.' }
          format.json { render :show, status: :ok, location: @event_prerequisites_event_type }
        else
          format.html { render :edit }
          format.json { render json: @event_prerequisites_event_type.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /event_prerequisites_event_types/1
    # DELETE /event_prerequisites_event_types/1.json
    def destroy
      @event_prerequisites_event_type.destroy
      respond_to do |format|
        format.html { redirect_to event_prerequisites_event_types_url, notice: 'Event prerequisites event type was successfully destroyed.' }
        format.json { head :no_content }
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_prerequisites_event_type
        @event_prerequisites_event_type = EventPrerequisitesEventType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_prerequisites_event_type_params
        params.require(:event_prerequisites_event_type).permit(:event_id, :event_type_id)
      end
  end
end
