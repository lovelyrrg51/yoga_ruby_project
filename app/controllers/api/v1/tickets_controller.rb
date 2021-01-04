module Api::V1
  class TicketsController < BaseController
    before_action :authenticate_user!, :except => [:test]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:test]
    before_action :set_ticket, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # include Mandrill::Rails::WebHookProcessor

    # GET /tickets
    def index
      # @tickets = policy_scope(Ticket)
      render json: @tickets
    end

    # GET /tickets/1
    def show
      authorize @ticket
      render json: @ticket
    end

    # GET /tickets/new
    def new
      @ticket = Ticket.new
    end

    # GET /tickets/1/edit
    def edit
    end

    # POST /tickets
    def create
      ticket_params_tmp = ticket_params
      ticket_params_tmp[:user_id] = current_user.id

      @ticket = Ticket.new(ticket_params_tmp)
      if @ticket.save
        render json: @ticket
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /tickets/1
    def update
      authorize @ticket
      if @ticket.update(ticket_params_update)
        render json: @ticket
      else
        render json: @ticket.errors, status: :unprocessable_entity
      end
    end

    # DELETE /tickets/1
    def destroy
      authorize @ticket
      res = @ticket.destroy
      render json: @ticket
    end

    def test
      UserMailer.test_response_email.deliver
      render json: params
    end

    def locate_collection
      if (params.has_key?("filter"))
        @tickets = TicketPolicy::Scope.new(current_user, Ticket).resolve(filtering_params)
      else
        @tickets = policy_scope(Ticket)
      end
    end


    private
      # Use callbacks to share common setup or constraints between actions.
      def set_ticket
        @ticket = Ticket.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def ticket_params
        params.require(:ticket).permit(:ticket_type_id, :title, :description, :priority, :ticket_cc, :ticketable_id, :ticketable_type)
      end

      def ticket_params_update
        params.require(:ticket).permit!
      end

      def filtering_params
        params.slice(:ticketable_id, :ticketable_type)
      end
  end
end
