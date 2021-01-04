module Api::V1
  class PgSyBraintreePaymentsController < BaseController
    require 'braintree'

    before_action :set_pg_sy_braintree_payment, only: [:show, :edit, :update, :destroy]
    respond_to :json

    # GET /pg_sy_braintree_payments
    def index
      @pg_sy_braintree_payments = PgSyBraintreePayment.all
      render json: @pg_sy_braintree_payments
    end

    # GET /pg_sy_braintree_payments/1
    def show
      authorize @pg_sy_braintree_payment
      render json: @pg_sy_braintree_payment
    end

    # GET /pg_sy_braintree_payments/new
    def new
      @pg_sy_braintree_payment = PgSyBraintreePayment.new
    end

    # GET /pg_sy_braintree_payments/1/edit
    def edit
    end

    def braintree_token
      if config_id = params[:config_id].presence
        if PgSyBraintreeConfig.configure(config_id)
          begin
            token = Braintree::ClientToken.generate
            render json: { token: token.to_s }
          rescue Braintree::BraintreeError => e
            render json: {errors: {error: [e.message]}}, status: :unprocessable_entity
          end
        else
          render json: {errors: {error: ['Braintree Configuration error']}}, status: :unprocessable_entity
        end
      else
        render json: {errors: {error: ['Parameters missing']}}, status: :unprocessable_entity
      end
    end

    # POST /pg_sy_braintree_payments
    def create
      @pg_sy_braintree_payment = PgSyBraintreePayment.new(pg_sy_braintree_payment_params)
      authorize @pg_sy_braintree_payment
      if @pg_sy_braintree_payment.save
        render json: @pg_sy_braintree_payment
      else
        render json: @pg_sy_braintree_payment.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /pg_sy_braintree_payments/1
    def update
      authorize @pg_sy_braintree_payment
      if @pg_sy_braintree_payment.update(pg_sy_braintree_payment_params)
        render json: @pg_sy_braintree_payment
      else
        render json: @pg_sy_braintree_payment.errors, status: :unprocessable_entity
      end
    end

    # DELETE /pg_sy_braintree_payments/1
    def destroy
      authorize @pg_sy_braintree_payment
      btp = @pg_sy_braintree_payment.destroy
      render json: btp
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sy_braintree_payment
        @pg_sy_braintree_payment = PgSyBraintreePayment.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sy_braintree_payment_params
        params.require(:pg_sy_braintree_payment).permit(:amount, :currency_iso_code, :braintree_payment_id, :refund_ids, :refunded_transaction_id, :status, :event_order_id)
      end
  end
end
