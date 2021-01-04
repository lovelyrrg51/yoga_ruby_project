module Api::V1
  class PgSyRazorpayPaymentsController < BaseController
    require 'razorpay'
    require 'razorpay/errors/razorpay_error'
    require 'httparty'

    before_action :set_pg_sy_razorpay_payment, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:create, :show]
    skip_before_action :verify_authenticity_token, only: [:create, :show]
    respond_to :json

    # GET /pg_sy_razorpay_payments
    def index
      @pg_sy_razorpay_payments = PgSyRazorpayPayment.all
      render json: @pg_sy_razorpay_payments
    end

    # GET /pg_sy_razorpay_payments/1
    def show
      authorize @pg_sy_razorpay_payment
      render json: @pg_sy_razorpay_payment
    end

    # GET /pg_sy_razorpay_payments/new
    def new
      @pg_sy_razorpay_payment = PgSyRazorpayPayment.new
    end

    # GET /pg_sy_razorpay_payments/1/edit
    def edit
    end

    # POST /pg_sy_razorpay_payments
    def create
      @pg_sy_razorpay_payment = PgSyRazorpayPayment.new(pg_sy_razorpay_payment_params)
      if @pg_sy_razorpay_payment.save
        render json: @pg_sy_razorpay_payment
      else
        render json: @pg_sy_razorpay_payment.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /pg_sy_razorpay_payments/1
    def update
      authorize @pg_sy_razorpay_payment
      if @pg_sy_razorpay_payment.update(pg_sy_razorpay_payment_params)
        render json: @pg_sy_razorpay_payment
      else
        render json: @pg_sy_razorpay_payment.errors, status: :unprocessable_entity
      end
    end

    # DELETE /pg_sy_razorpay_payments/1
    def destroy
      authorize @pg_sy_razorpay_payment
      rp = @pg_sy_razorpay_payment.destroy
      render json: rp
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_razorpay_payment
        @pg_sy_razorpay_payment = PgSyRazorpayPayment.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_razorpay_payment_params
        params.require(:pg_sy_razorpay_payment).permit(:entity, :amount, :currency, :status, :description, :refund_status, :amount_refunded, :notes, :pg_sy_razorpay_merchant_id, :razorpay_payment_id, :refund_id, :event_order_id)
      end
  end
end
