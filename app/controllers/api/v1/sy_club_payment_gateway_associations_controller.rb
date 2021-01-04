module Api::V1
  class SyClubPaymentGatewayAssociationsController < BaseController
    before_action :set_sy_club_payment_gateway_association, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :create, :show]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :show]
    respond_to :json
  
    # GET /sy_club_payment_gateway_associations
    def index
      render json: @sy_club_payment_gateway_associations
    end
  
    # GET /sy_club_payment_gateway_associations/1
    def show
    end
  
    # GET /sy_club_payment_gateway_associations/new
    def new
      @sy_club_payment_gateway_association = SyClubPaymentGatewayAssociation.new
    end
  
    # GET /sy_club_payment_gateway_associations/1/edit
    def edit
    end
  
    # POST /sy_club_payment_gateway_associations
    def create
      @sy_club_payment_gateway_association = SyClubPaymentGatewayAssociation.new(sy_club_payment_gateway_association_params)
      authorize @sy_club_payment_gateway_association
      if @sy_club_payment_gateway_association.save
       render json: @sy_club_payment_gateway_association
      else
       render json: @sy_club_payment_gateway_association.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_club_payment_gateway_associations/1
    def update
      authorize @sy_club_payment_gateway_association
      if @sy_club_payment_gateway_association.update(sy_club_payment_gateway_association_params)
        render json: @sy_club_payment_gateway_association
      else
        render json: @sy_club_payment_gateway_association.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_club_payment_gateway_associations/1
    def destroy
      authorize @sy_club_payment_gateway_association
      sy_payment_destroy = @sy_club_payment_gateway_association.destroy
      render json: sy_payment_destroy
    end
  
    def locate_collection
      if params.has_key?("filter")
        @sy_club_payment_gateway_associations = SyClubPaymentGatewayAssociationPolicy::Scope.new(current_user, SyClubPaymentGatewayAssociation).resolve(filtering_params)
      else
        @sy_club_payment_gateway_associations = policy_scope(SyClubPaymentGatewayAssociation)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_club_payment_gateway_association
        @sy_club_payment_gateway_association = SyClubPaymentGatewayAssociation.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_club_payment_gateway_association_params
        params.require(:sy_club_payment_gateway_association).permit(:payment_gateway_id, :payment_start_date, :payment_end_date) #:sy_club_id,
      end
  
      def filtering_params
        params.slice(:sy_club_id)
      end
  end
end
