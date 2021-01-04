module Api::V1
  class PaymentRefundLineItemsController < BaseController
    before_action :set_payment_refund_line_item, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: []
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /payment_refund_line_items
    def index
      render json: @payment_refund_line_items
    end
  
    # GET /payment_refund_line_items/1
    def show
      authorize @payment_refund_line_item
      render json: @payment_refund_line_item
    end
  
    # GET /payment_refund_line_items/new
    def new
      render json: {}
    end
  
    # GET /payment_refund_line_items/1/edit
    def edit
      render json: {}
    end
  
    # POST /payment_refund_line_items
    def create
      @payment_refund_line_item = PaymentRefundLineItem.new(payment_refund_line_item_params)
      authorize @payment_refund_line_item
      if @payment_refund_line_item.save
        render json: @payment_refund_line_item
      else
        render json: @payment_refund_line_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /payment_refund_line_items/1
    def update
      authorize @payment_refund_line_item
      if @payment_refund_line_item.update(payment_refund_line_item_params)
        render json: @payment_refund_line_item
      else
        render json: @payment_refund_line_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /payment_refund_line_items/1
    def destroy
      authorize @payment_refund_line_item
      if @payment_refund_line_item.destroy
        render json: @payment_refund_line_item
      else
        render json: @payment_refund_line_item.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # Locate collection
    def locate_collection
      if params.has_key?("filter")
        @payment_refund_line_items = PaymentRefundLineItemPolicy::Scope.new(current_user, PaymentRefundLineItem.preloaded_data).resolve(filtering_params)
      else
        @payment_refund_line_items = policy_scope(PaymentRefundLineItem.preloaded_data)
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_payment_refund_line_item
        @payment_refund_line_item = PaymentRefundLineItem.preloaded_data.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def payment_refund_line_item_params
        params.require(:payment_refund_line_item).permit(:sadhak_profile_id, :event_registration_id, :status, :event_id, :event_seating_category_association_id, :is_deleted, :payment_refund_id)
      end
  
      def filtering_params
        params.slice(:sadhak_profile_id, :event_registration_id, :status, :event_id, :event_seating_category_association_id, :payment_refund_id)
      end
  end
end
