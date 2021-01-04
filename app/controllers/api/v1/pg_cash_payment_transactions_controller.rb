module Api::V1
  class PgCashPaymentTransactionsController < BaseController
    before_action :set_pg_cash_payment_transaction, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    respond_to :json

    # GET /pg_cash_payment_transactions
    def index
      @pg_cash_payment_transactions = PgCashPaymentTransaction.all
      render json: @pg_cash_payment_transactions
    end

    # GET /pg_cash_payment_transactions/1
    def show
    end

    # GET /pg_cash_payment_transactions/new
    def new
      @pg_cash_payment_transaction = PgCashPaymentTransaction.new
    end

    # GET /pg_cash_payment_transactions/1/edit
    def edit
    end

    # POST /pg_cash_payment_transactions
    def create
      @pg_cash_payment_transaction = PgCashPaymentTransaction.new(pg_cash_payment_transaction_params)
      if @pg_cash_payment_transaction.save
        render json: @pg_cash_payment_transaction
      else
        render json: @pg_cash_payment_transaction.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /pg_cash_payment_transactions/1
    def update
      if @pg_cash_payment_transaction.update(pg_cash_payment_transaction_params)
        render json: @pg_cash_payment_transaction
      else
        render json: @pg_cash_payment_transaction.errors, status: :unprocessable_entity
      end
    end

    # DELETE /pg_cash_payment_transactions/1
    def destroy
     pg_cp =  @pg_cash_payment_transaction.destroy
     render json: pg_cp
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_cash_payment_transaction
        @pg_cash_payment_transaction = PgCashPaymentTransaction.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_cash_payment_transaction_params
        params.require(:pg_cash_payment_transaction).permit(:amount, :status, :payment_date, :is_terms_accepted, :additional_details, :event_order_id, :transaction_number)
      end
  end
end
