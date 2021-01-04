module Api::V1
  class TicketResponsesController < BaseController
    before_action :authenticate_user!
    before_action :locate_collection, :only => :index
    before_action :set_ticket_response, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /ticket_responses
    def index
      # @ticket_responses = policy_scope(TicketResponse)
      render json: @ticket_responses
    end
  
    # GET /ticket_responses/1
    def show
      render json: @ticket_response
    end
  
    # GET /ticket_responses/new
    def new
      @ticket_response = TicketResponse.new
    end
  
    # GET /ticket_responses/1/edit
    def edit
    end
  
    # POST /ticket_responses
    def create
      ticket_response_params_tmp = ticket_response_params
      ticket_response_params_tmp[:user_id] = current_user.id
      @ticket_response = TicketResponse.new(ticket_response_params_tmp)
      authorize @ticket_response
      if @ticket_response.save
        render json: @ticket_response
      else
        render json: @ticket_response.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /ticket_responses/1
    def update
      authorize @ticket_response
      if @ticket_response.update(ticket_response_params)
        render json: @ticket_response
      else
        render json: @ticket_response.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /ticket_responses/1
    def destroy
      authorize @ticket_response
      @ticket_response.destroy
      render json: @ticket_response
    end
  
    def locate_collection
      if (params.has_key?("filter"))
        @ticket_responses = TicketResponsePolicy::Scope.new(current_user, TicketResponse).resolve(filtering_params)
      else
        @ticket_responses = policy_scope(TicketResponse)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket_response
        @ticket_response = TicketResponse.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def ticket_response_params
        params.require(:ticket_response).permit(:ticket_id, :response,:status)
      end
  
      def filtering_params
        params.slice(:ticket_id)
      end
  end
end
