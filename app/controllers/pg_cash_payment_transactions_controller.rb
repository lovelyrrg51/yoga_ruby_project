class PgCashPaymentTransactionsController < ApplicationController
  before_action :set_pg_cash_payment_transaction, only: [:show, :edit, :update, :destroy]

  # GET /pg_cash_payment_transactions
  def index
    @pg_cash_payment_transactions = PgCashPaymentTransaction.all
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
      redirect_to @pg_cash_payment_transaction, notice: 'Pg cash payment transaction was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /pg_cash_payment_transactions/1
  def update
    if @pg_cash_payment_transaction.update(pg_cash_payment_transaction_params)
      redirect_to @pg_cash_payment_transaction, notice: 'Pg cash payment transaction was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /pg_cash_payment_transactions/1
  def destroy
    @pg_cash_payment_transaction.destroy
    redirect_to pg_cash_payment_transactions_url, notice: 'Pg cash payment transaction was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pg_cash_payment_transaction
      @pg_cash_payment_transaction = PgCashPaymentTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pg_cash_payment_transaction_params
      params[:pg_cash_payment_transaction]
    end
end
