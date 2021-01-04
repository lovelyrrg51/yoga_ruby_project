module Api::V1
  class EventSeatingCategoryAssociationsController < BaseController
    before_action :set_event_seating_category_association, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index]
    respond_to :json
  
    # GET /event_seating_category_associations
    def index
      #@event_seating_category_associations = policy_scope(EventSeatingCategoryAssociation)
      event_id = params[:event][:id]
  #     seating_category_id = params[:seating_category][:id]
      @event_seating_category_associations = EventSeatingCategoryAssociation.where(:event_id => event_id).includes(:event, :seating_category).order(:price)
      render json: @event_seating_category_associations
    end
  
    # GET /event_seating_category_associations/1
    def show
      authorize @event_seating_category_association
      render json: @event_seating_category_association
    end
  
    # GET /event_seating_category_associations/new
    def new
      @event_seating_category_association = EventSeatingCategoryAssociation.new
    end
  
    # GET /event_seating_category_associations/1/edit
    def edit
    end
  
    # POST /event_seating_category_associations
    def create
      @event_seating_category_association = EventSeatingCategoryAssociation.new(event_seating_category_association_params)
      authorize @event_seating_category_association
      if @event_seating_category_association.save
          render json: @event_seating_category_association
      else
        render json: @event_seating_category_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /event_seating_category_associations/1
    def update
      authorize @event_seating_category_association
      if @event_seating_category_association.update(event_seating_category_association_params)
        render json: @event_seating_category_association
      else
        render json: @event_seating_category_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /event_seating_category_associations/1
    def destroy
      authorize @event_seating_category_association
      if @event_seating_category_association.update(is_deleted: true)
        render json: @event_seating_category_association
      else
        render json: @event_seating_category_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_event_seating_category_association
        @event_seating_category_association = EventSeatingCategoryAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def event_seating_category_association_params
        params.require(:event_seating_category_association).permit(:event_id, :seating_category_id, :price, :seating_capacity, :cancellation_charge)
      end
  #   def event_params
  #     params.require(:event_seating_category_association).permit(:id)
  #   end
  end
end
