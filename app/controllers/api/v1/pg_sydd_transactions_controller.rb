module Api::V1
  class PgSyddTransactionsController < BaseController
    require "base64"
    before_action :set_pg_sydd_transaction, only: [:show, :edit, :update, :destroy]
  skip_before_action :verify_authenticity_token
    # GET /pg_sydd_transactions
    def index
      @pg_sydd_transactions = PgSyddTransaction.all
      render json: @pg_sydd_transactions
    end

    # GET /pg_sydd_transactions/1
    def show

    end

    # GET /pg_sydd_transactions/new
    def new
       render json: 'hai'
      return false
      @pg_sydd_transaction = PgSyddTransaction.new
    end

    # GET /pg_sydd_transactions/1/edit
    def edit
    end

    # POST /pg_sydd_transactions
    def create
      pg_sydd_transaction_params[:registration_number] = @registration_number
      @pg_sydd_transaction = PgSyddTransaction.new(pg_sydd_transaction_params)
        if  @pg_sydd_transaction.save
          render json: @pg_sydd_transaction
        else
          render json: @pg_sydd_transaction.errors, status: :unprocessable_entity
        end
    end

    # PATCH/PUT /pg_sydd_transactions/1
    def update
      if @pg_sydd_transaction.update(pg_sydd_transaction_params)
        render json: @pg_sydd_transaction
      else
        render json: @pg_sydd_transaction.errors, status: :unprocessable_entity
      end
    end

    # DELETE /pg_sydd_transactions/1
    def destroy
      @pg_sydd_transaction.destroy
      respond_to do |format|
        format.html { redirect_to pg_sydd_transactions_url, notice: 'Pg sydd transaction was successfully destroyed.' }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_pg_sydd_transaction
        @pg_sydd_transaction = PgSyddTransaction.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def pg_sydd_transaction_params
        params.require(:pg_sydd_transaction).permit(:dd_number, :pg_sydd_merchant_id, :dd_date, :bank_name, :amount, :additional_details, :is_terms_accepted, :event_order_id)
      end
  end
end
