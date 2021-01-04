class PgSyBraintreeConfigsController < ApplicationController

  before_action :set_payment_gateway_type, only:[:index, :create, :edit, :new]
  before_action :set_pg_sy_braintree_config, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @pg_sy_braintree_config = PgSyBraintreeConfig.new

    authorize(@pg_sy_braintree_config)

    @payment_gateway_type_name = @payment_gateway_type.name

    @pg_sy_braintree_configs = PgSyBraintreeConfig.page(params[:page]).per(params[:per_page])

  end

  def create

    begin
        
      @pg_sy_braintree_config = @payment_gateway_type.payment_gateways.build.build_pg_sy_braintree_config(pg_sy_braintree_config_params)

      authorize(@pg_sy_braintree_config)

      if @pg_sy_braintree_config.save
        flash[:success] = "Braintree Configuration is successfully created."
      else
        flash[:error] = @pg_sy_braintree_config.errors.full_messages.first
      end

      redirect_to pg_sy_braintree_configs_path

    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def edit

    authorize(@pg_sy_braintree_config)

    @payment_gateway_type_name = @payment_gateway_type.name

  end

  def update

    authorize(@pg_sy_braintree_config)

    if @pg_sy_braintree_config.update(pg_sy_braintree_config_params)
      flash[:success] = "Braintree Configuration is successfully updated."
    else
      flash[:error] = @pg_sy_braintree_config.errors.full_messages.first
    end

    redirect_to pg_sy_braintree_configs_path


  end

  def destroy

    authorize(@pg_sy_braintree_config)

    begin

      @pg_sy_braintree_config.destroy!
      
    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:error] = message
    else
      flash[:success] = "Braintree Configuration is successfully destroyed."
    end

    redirect_to pg_sy_braintree_configs_path

  end

  private

  def pg_sy_braintree_config_params
    params.require(:pg_sy_braintree_config).permit(:alias_name, :publishable_key, :secret_key, :merchant_id, :country_id, :tax_amount)
  end

  def set_payment_gateway_type
    @payment_gateway_type = PaymentGatewayType.find_by_config_model_name(controller_name.classify)
  end

  def set_pg_sy_braintree_config
    @pg_sy_braintree_config = PgSyBraintreeConfig.find(params[:id])
  end

end
