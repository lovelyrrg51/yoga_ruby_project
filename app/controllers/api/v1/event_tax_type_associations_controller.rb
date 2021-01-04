module Api::V1
  class EventTaxTypeAssociationsController < BaseController
    before_action :authenticate_user!
    before_action :set_event_tax_type_association, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /event_tax_type_associations
    def index
      @event_tax_type_associations = policy_scope(EventTaxTypeAssociation)
      render json: @event_tax_type_associations
    end
  
    # GET /event_tax_type_associations/1
    def show
    end
  
    # GET /event_tax_type_associations/new
    def new
      @event_tax_type_association = EventTaxTypeAssociation.new
    end
  
    # GET /event_tax_type_associations/1/edit
    def edit
    end
  
    # POST /event_tax_type_associations
    def create
      @event_tax_type_association = EventTaxTypeAssociation.new(event_tax_type_association_params)
      authorize  @event_tax_type_association
        if @event_tax_type_association.save
          render json: @event_tax_type_association
        else
         render json: @event_tax_type_association.errors, status: :unprocessable_entity
        end
    end
  
    # PATCH/PUT /event_tax_type_associations/1
    def update
      authorize  @event_tax_type_association
      if @event_tax_type_association.update(event_tax_type_association_params)
        render json: @event_tax_type_association
      else
        render json: @event_tax_type_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /event_tax_type_associations/1
    def destroy
      authorize  @event_tax_type_association
      if @event_tax_type_association.update(is_deleted: true)
        render json: @event_tax_type_association
      else
        render json: @event_tax_type_association.errors, status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_tax_type_association
        @event_tax_type_association = EventTaxTypeAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_tax_type_association_params
        params.require(:event_tax_type_association).permit(:percent, :sequence, :event_id, :tax_type_id)
      end
  end
end
