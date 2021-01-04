module Api::V1
  class TicketTypesController < BaseController
    before_action :authenticate_user!
    before_action :set_ticket_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ticket_types
    def index
      @ticket_types = policy_scope(TicketType)
      render json: @ticket_types
    end
  
    # GET /ticket_types/1
    def show
      render json: @ticket_type
    end
  
    # GET /ticket_types/new
    def new
      @ticket_type = TicketType.new
    end
  
    # GET /ticket_types/1/edit
    def edit
    end
  
    # POST /ticket_types
    def create
      @ticket_type = TicketType.new(ticket_type_params)
      authorize @ticket_type
      if @ticket_type.save
        render json: @ticket_type
      else
        render json: @ticket_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ticket_types/1
    def update
      authorize @ticket_type
      if @ticket_type.update(ticket_type_params)
        render json: @ticket_type
      else
        render json: @ticket_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ticket_types/1
    def destroy
      authorize @ticket_type
      res = @ticket_type.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_type
        @ticket_type = TicketType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ticket_type_params
        params.require(:ticket_type).permit(:ticket_type, :ticket_group_id)
      end
  end
end
