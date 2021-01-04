module Api::V1
  class PgSywiretransferTransactionsController < BaseController
    before_action :set_pg_sywiretransfer_transaction, only: [:show, :edit, :update, :destroy]
  
    # GET /pg_sywiretransfer_transactions
    def index
      @pg_sywiretransfer_transactions = policy_scope(PgSywiretransferTransaction)
      render json: @pg_sywiretransfer_transactions
    end
  
    # GET /pg_sywiretransfer_transactions/1
    def show
    end
  
    # GET /pg_sywiretransfer_transactions/new
    def new
      @pg_sywiretransfer_transaction = PgSywiretransferTransaction.new
    end
  
    # GET /pg_sywiretransfer_transactions/1/edit
    def edit
    end
  
    # POST /pg_sywiretransfer_transactions
    def create
      @pg_sywiretransfer_transaction = PgSywiretransferTransaction.new(pg_sywiretransfer_transaction_params)
      if @pg_sywiretransfer_transaction.save
        render json: @pg_sywiretransfer_transaction
      else
        render json: @pg_sywiretransfer_transaction.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /pg_sywiretransfer_transactions/1
    def update
      if @pg_sywiretransfer_transaction.update(pg_sywiretransfer_transaction_params)
        render json: @pg_sywiretransfer_transaction
      else
        render json: @pg_sywiretransfer_transaction.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /pg_sywiretransfer_transactions/1
    def destroy
      pwtt = @pg_sywiretransfer_transaction.destroy
      render json: pwtt
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sywiretransfer_transaction
        @pg_sywiretransfer_transaction = PgSywiretransferTransaction.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sywiretransfer_transaction_params
        params.require(:pg_sywiretransfer_transaction).permit(:date_of, :amount, :bank_reference_id, :remitters_bank_details, :beneficiary_bank_details, :currency, :pg_sywiretransfer_merchants_id)
      end
  end
end
