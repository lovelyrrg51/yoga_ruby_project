class StripeConfigsController < ApplicationController

  before_action :set_payment_gateway_type, only:[:index, :create, :edit, :new]
  before_action :set_stripe_config, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @stripe_config = StripeConfig.new

    authorize(@stripe_config)

    @payment_gateway_type_name = @payment_gateway_type.name

    @stripe_configs = StripeConfig.page(params[:page]).per(params[:per_page])

  end

  def create

    begin

      @stripe_config = @payment_gateway_type.payment_gateways.build.build_stripe_config(stripe_config_params)

      authorize(@stripe_config)

      if @stripe_config.save
        flash[:success] = "Stripe Configuration is successfully created."
      else
        flash[:error] = @stripe_config.errors.full_messages.first
      end

      redirect_to stripe_configs_path
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def edit

    authorize(@stripe_config)

    @payment_gateway_type_name = @payment_gateway_type.name

  end

  def update

    authorize(@stripe_config)

    if @stripe_config.update(stripe_config_params)
      flash[:success] = "Stripe Configuration is successfully updated."
    else
      flash[:error] = @stripe_config.errors.full_messages.first
    end

    redirect_to stripe_configs_path


  end

  def destroy

    authorize(@stripe_config)

    begin

      @stripe_config.destroy!
      
    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:error] = message
    else
      flash[:success] = "Stripe Configuration is successfully destroyed."
    end

    redirect_to stripe_configs_path

  end

  private

  def stripe_config_params
    params.require(:stripe_config).permit(:alias_name, :publishable_key, :secret_key, :merchant_id, :country_id, :tax_amount)
  end

  def set_payment_gateway_type
    @payment_gateway_type = PaymentGatewayType.find_by_config_model_name(controller_name.classify)
  end

  def set_stripe_config
    @stripe_config = StripeConfig.find(params[:id])
  end
end
