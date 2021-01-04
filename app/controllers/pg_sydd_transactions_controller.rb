class PgSyddTransactionsController < ApplicationController
  before_action :set_pg_sydd_transaction, only: [:show, :edit, :update, :destroy]

  # GET /pg_sydd_transactions
  def index
    @pg_sydd_transactions = PgSyddTransaction.all
  end

  # GET /pg_sydd_transactions/1
  def show
  end

  # GET /pg_sydd_transactions/new
  def new
    @pg_sydd_transaction = PgSyddTransaction.new
  end

  # GET /pg_sydd_transactions/1/edit
  def edit
  end

  # POST /pg_sydd_transactions
  def create
    @pg_sydd_transaction = PgSyddTransaction.new(pg_sydd_transaction_params)

    if @pg_sydd_transaction.save
      redirect_to @pg_sydd_transaction, notice: 'Pg sydd transaction was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /pg_sydd_transactions/1
  def update
    if @pg_sydd_transaction.update(pg_sydd_transaction_params)
      redirect_to @pg_sydd_transaction, notice: 'Pg sydd transaction was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /pg_sydd_transactions/1
  def destroy
    @pg_sydd_transaction.destroy
    redirect_to pg_sydd_transactions_url, notice: 'Pg sydd transaction was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pg_sydd_transaction
      @pg_sydd_transaction = PgSyddTransaction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pg_sydd_transaction_params
      params[:pg_sydd_transaction]
    end
end
