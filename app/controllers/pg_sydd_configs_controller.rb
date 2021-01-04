class PgSyddConfigsController < ApplicationController  

  before_action :set_payment_gateway_type, only:[:index, :create, :edit, :new]
  before_action :set_pg_sydd_config, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @pg_sydd_config = PgSyddConfig.new

    authorize(@pg_sydd_config)

    @payment_gateway_type_name = @payment_gateway_type.name

    @pg_sydd_configs = PgSyddConfig.page(params[:page]).per(params[:per_page])

  end

  def create

    begin

      @pg_sydd_config = @payment_gateway_type.payment_gateways.build.build_pg_sydd_config(pg_sydd_config_params)

      authorize(@pg_sydd_config)

      if @pg_sydd_config.save
        flash[:success] = "DD Configuration is successfully created."
      else
        flash[:error] = @pg_sydd_config.errors.full_messages.first
      end

      redirect_to pg_sydd_configs_path
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def edit

    authorize(@pg_sydd_config)

    @payment_gateway_type_name = @payment_gateway_type.name

  end

  def update

    authorize(@pg_sydd_config)

    if @pg_sydd_config.update(pg_sydd_config_params)
      flash[:success] = "DD Configuration is successfully Updated."
    else
      flash[:error] = @pg_sydd_config.errors.full_messages.first
    end

    redirect_to pg_sydd_configs_path


  end

  def destroy

    authorize(@pg_sydd_config)

    begin

      @pg_sydd_config.destroy!
      
    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:error] = message
    else
      flash[:success] = "DD Configuration is successfully destroyed."
    end

    redirect_to pg_sydd_configs_path

  end

  private

  def pg_sydd_config_params
    params.require(:pg_sydd_config).permit(:alias_name, :public_key, :private_key, :pg_sydd_merchant_id, :country_id, :tax_amount)
  end

  def set_payment_gateway_type
    @payment_gateway_type = PaymentGatewayType.find_by_config_model_name(controller_name.classify)
  end

  def set_pg_sydd_config
    @pg_sydd_config = PgSyddConfig.find(params[:id])
  end
end
