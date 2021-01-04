class PaymentGatewayModeAssociationRangesController < ApplicationController
  before_action :set_payment_gateway_mode_association_range, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: []
  skip_before_action :verify_authenticity_token, only: []
  before_action :locate_collection, only: :index

  # GET /payment_gateway_mode_association_ranges
  def index
    render json: @payment_gateway_mode_association_ranges, serializer: PaginationSerializer
  end

  # GET /payment_gateway_mode_association_ranges/1
  def show
    render json: @payment_gateway_mode_association_range
  end

  # GET /payment_gateway_mode_association_ranges/new
  def new
    @payment_gateway_mode_association_range = PaymentGatewayModeAssociationRange.new
  end

  # GET /payment_gateway_mode_association_ranges/1/edit
  def edit
  end

  # POST /payment_gateway_mode_association_ranges
  def create
    @payment_gateway_mode_association_range = PaymentGatewayModeAssociationRange.new(payment_gateway_mode_association_range_params)
    authorize @payment_gateway_mode_association_range
    
    if @payment_gateway_mode_association_range.save
      render json: @payment_gateway_mode_association_range
    else
      render json: @payment_gateway_mode_association_range.errors.as_json(full_messages: true), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment_gateway_mode_association_ranges/1
  def update
    authorize @payment_gateway_mode_association_range
    if @payment_gateway_mode_association_range.update(payment_gateway_mode_association_range_params)
      render json: @payment_gateway_mode_association_range
    else
      render json: @payment_gateway_mode_association_range.errors.as_json(full_messages: true), status: :unprocessable_entity
    end
  end

  # DELETE /payment_gateway_mode_association_ranges/1
  def destroy
    authorize @payment_gateway_mode_association_range
    @payment_gateway_mode_association_range.destroy
    render json: @payment_gateway_mode_association_range
  end

  def locate_collection
    if params[:page].present?
      @payment_gateway_mode_association_ranges = PaymentGatewayModeAssociationRangePolicy::Scope.new(current_user, PaymentGatewayModeAssociationRange).resolve(filtering_params).page(params[:page]).per(params[:per_page])
    else
      @payment_gateway_mode_association_ranges = PaymentGatewayModeAssociationRangePolicy::Scope.new(current_user, PaymentGatewayModeAssociationRange).resolve(filtering_params)
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_payment_gateway_mode_association_range
    @payment_gateway_mode_association_range = PaymentGatewayModeAssociationRange.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_gateway_mode_association_range_params
    params.require(:payment_gateway_mode_association_range).permit(:min_value, :max_value, :percent, :payment_gateway_mode_association_id, :deleted_at)
  end

  def filtering_params
    params.slice(:payment_gateway_mode_association_id, :payment_gateway_id, :payment_mode_id)
  end
end
