class PaymentModesController < ApplicationController
  before_action :set_payment_mode, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: []
  before_action :locate_collection, only: :index

  # GET /payment_modes
  def index

    authorize @payment_modes

    @payment_mode = PaymentMode.new

  end

  # GET /payment_modes/1
  def show
    render json: @payment_mode
  end

  # GET /payment_modes/new
  def new
    @payment_mode = PaymentMode.new
  end

  # GET /payment_modes/1/edit
  def edit

    authorize @payment_mode

  end

  # POST /payment_modes
  def create

    begin
      PaymentMode.create!(payment_mode_params)
    rescue Exception => e
      message = e.message
    end

    message.present? ? flash[:alert] = e.message : flash[:success] = "Payment Mode is successfully created."
    redirect_to payment_modes_path

  end

  # PATCH/PUT /payment_modes/1
  def update

    authorize @payment_mode

    begin
      @payment_mode.update!(payment_mode_params)
    rescue Exception => e
      message = e.message
    end

    message.present? ? flash[:alert] = e.message : flash[:success] = "Payment Mode is successfully updated."
    redirect_to payment_modes_path

  end

  # DELETE /payment_modes/1
  def destroy
    authorize @payment_mode

    begin
      @payment_mode.destroy!
    rescue Exception => e
      message = e.message
    end
    
    message.present? ? flash[:alert] = e.message : flash[:success] = "Payment Mode is successfully destroyed."
    redirect_to payment_modes_path

  end

  def locate_collection
    @payment_modes = PaymentModePolicy::Scope.new(current_user, PaymentMode).resolve(filtering_params).page(params[:page]).per(params[:per_page])
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_payment_mode
    @payment_mode = PaymentMode.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def payment_mode_params
    params.require(:payment_mode).permit(:name, :shortcode, :group_name)
  end

  def filtering_params
    params.slice(:group_name, :shortcode, :mode_name)
  end
end
