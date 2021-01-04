class PaymentGatewayModeAssociationTaxTypesController < ApplicationController
  before_action :set_payment_gateway_mode_association_tax_type, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: []
  skip_before_action :verify_authenticity_token, only: []
  before_action :locate_collection, only: :index

  # GET /payment_gateway_mode_association_tax_types
  def index
    render json: @payment_gateway_mode_association_tax_types, serializer: PaginationSerializer
  end

  # GET /payment_gateway_mode_association_tax_types/1
  def show
    render json: @payment_gateway_mode_association_tax_type
  end

  # GET /payment_gateway_mode_association_tax_types/new
  def new
    @payment_gateway_mode_association_tax_type = PaymentGatewayModeAssociationTaxType.new
  end

  # GET /payment_gateway_mode_association_tax_types/1/edit
  def edit
  end

  # POST /payment_gateway_mode_association_tax_types
  def create
    @payment_gateway_mode_association_tax_type = PaymentGatewayModeAssociationTaxType.new(payment_gateway_mode_association_tax_type_params)
    authorize @payment_gateway_mode_association_tax_type

    if @payment_gateway_mode_association_tax_type.save
      render json: @payment_gateway_mode_association_tax_type
    else
      render json: @payment_gateway_mode_association_tax_type.errors.as_json(full_messages: true), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /payment_gateway_mode_association_tax_types/1
  def update
    authorize @payment_gateway_mode_association_tax_type
    if @payment_gateway_mode_association_tax_type.update(payment_gateway_mode_association_tax_type_params)
      render json: @payment_gateway_mode_association_tax_type
    else
      render json: @payment_gateway_mode_association_tax_type.errors.as_json(full_messages: true), status: :unprocessable_entity
    end
  end

  # DELETE /payment_gateway_mode_association_tax_types/1
  def destroy
    authorize @payment_gateway_mode_association_tax_type
    @payment_gateway_mode_association_tax_type.destroy
    render json: @payment_gateway_mode_association_tax_type
  end

  def locate_collection
    if params[:page].present?
      @payment_gateway_mode_association_tax_types = PaymentGatewayModeAssociationTaxTypePolicy::Scope.new(current_user, PaymentGatewayModeAssociationTaxType).resolve(filtering_params).page(params[:page]).per(params[:per_page])
    else
      @payment_gateway_mode_association_tax_types = PaymentGatewayModeAssociationTaxTypePolicy::Scope.new(current_user, PaymentGatewayModeAssociationTaxType).resolve(filtering_params)
    end
  end

  private
 
  # Use callbacks to share common setup or constraints between actions.
  def set_payment_gateway_mode_association_tax_type
    @payment_gateway_mode_association_tax_type = PaymentGatewayModeAssociationTaxType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_gateway_mode_association_tax_type_params
    params.require(:payment_gateway_mode_association_tax_type).permit(:tax_type_id, :payment_gateway_mode_association_id, :percent)
  end

  def filtering_params
    params.slice(:payment_gateway_mode_association_id, :tax_type_id)
  end
end
