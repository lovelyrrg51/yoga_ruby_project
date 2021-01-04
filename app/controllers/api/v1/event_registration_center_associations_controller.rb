module Api::V1
  class EventRegistrationCenterAssociationsController < BaseController
    before_action :authenticate_user!
    before_action :set_event_registration_center_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_registration_center_associations
    def index
      @event_registration_center_associations = policy_scope(EventRegistrationCenterAssociation)
      render json: @event_registration_center_associations
    end
  
    # GET /event_registration_center_associations/1
    def show
    end
  
    # GET /event_registration_center_associations/new
    def new
      @event_registration_center_association = EventRegistrationCenterAssociation.new
    end
  
    # GET /event_registration_center_associations/1/edit
    def edit
    end
  
    # POST /event_registration_center_associations
    def create
      @event_registration_center_association = EventRegistrationCenterAssociation.new(event_registration_center_association_params)
      authorize @event_registration_center_association
      if @event_registration_center_association.save
        render json: @event_registration_center_association
      else
        render json: @event_registration_center_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_registration_center_associations/1
    def update
      authorize @event_registration_center_association
      if @event_registration_center_association.update(event_registration_center_association_params)
        render json: @event_registration_center_association
      else
        render json: @event_registration_center_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_registration_center_associations/1
    def destroy
      authorize @event_registration_center_association
      rgc = @event_registration_center_association.destroy
      render json: rgc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_registration_center_association
        @event_registration_center_association = EventRegistrationCenterAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_registration_center_association_params
        params.require(:event_registration_center_association).permit(:event_id, :registration_center_id, :is_cash_payment_allowed)
      end
  end
end
