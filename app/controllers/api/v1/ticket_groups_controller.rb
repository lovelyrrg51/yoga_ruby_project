module Api::V1
  class TicketGroupsController < BaseController
    before_action :authenticate_user!
    before_action :set_ticket_group, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ticket_groups
    def index
      @ticket_groups = policy_scope(TicketGroup)
      render json: @ticket_groups
    end
  
    # GET /ticket_groups/1
    def show
      authorize @ticket_group
      render json: @ticket_group
    end
  
    # GET /ticket_groups/new
    def new
      @ticket_group = TicketGroup.new
    end
  
    # GET /ticket_groups/1/edit
    def edit
    end
  
    # POST /ticket_groups
    def create
      @ticket_group = TicketGroup.new(ticket_group_params)
      authorize @ticket_group
      if @ticket_group.save
        render json: @ticket_group
      else
        render json: @ticket_group.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ticket_groups/1
    def update
      authorize @ticket_group
      if @ticket_group.update(ticket_group_params)
        render json: @ticket_group
      else
        render json: @ticket_group.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ticket_groups/1
    def destroy
      authorize @ticket_group
      res = @ticket_group.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_group
        @ticket_group = TicketGroup.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ticket_group_params
        params.require(:ticket_group).permit!
      end
  end
end
