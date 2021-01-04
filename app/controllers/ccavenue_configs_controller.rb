class CcavenueConfigsController < ApplicationController

  before_action :set_payment_gateway_type, only:[:index, :create, :edit]
  before_action :set_ccavenue_config, only:[:edit, :update, :destroy, :payment_modes]
  before_action :set_payment_gateway, only: [:payment_modes]
  before_action :authenticate_user!

  def index

    @ccavenue_config = CcavenueConfig.new

    authorize(@ccavenue_config)

    @payment_gateway_type_name = @payment_gateway_type.name

    @ccavenue_configs = CcavenueConfig.page(params[:page]).per(params[:per_page])

  end

  def create

    begin

      @ccavenue_config = @payment_gateway_type.payment_gateways.build.build_ccavenue_config(ccavenue_config_params)

      authorize(@ccavenue_config)

      if @ccavenue_config.save
        flash[:success] = "Ccavenue Configuration is successfully created."
      else
        flash[:error] = @ccavenue_config.errors.full_messages.first
      end

      redirect_to ccavenue_configs_path
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def edit

    authorize(@ccavenue_config)

    @payment_gateway_type_name = @payment_gateway_type.name

  end

  def update

    authorize(@ccavenue_config)

    if @ccavenue_config.update(ccavenue_config_params)
      flash[:success] = "Ccavenue Configuration is successfully updated."
    else
      flash[:error] = @ccavenue_config.errors.full_messages.first
    end

    redirect_to ccavenue_configs_path


  end

  def destroy

    authorize(@ccavenue_config)

    begin

      @ccavenue_config.destroy!
      
    rescue Exception => e
      message = e.message
    end

    if message.present?
      flash[:error] = message
    else
      flash[:success] = "Ccavenue Configuration is successfully destroyed."
    end

    redirect_to ccavenue_configs_path

  end

  def payment_modes

    begin

      authorize @ccavenue_config

      raise "No Payment Gateway is Associated with this Config" unless @payment_gateway.present? 

      @payment_modes = PaymentMode.order(:id)

      if @payment_modes.count.nonzero?

        @payment_mode = @payment_modes.first

        if @payment_mode.payment_gateways.include?(@payment_gateway)

          @payment_gateway_mode_association = helpers.get_payment_gateway_mode_association(@payment_gateway, @payment_mode)

        else

          @payment_gateway_mode_association = @payment_gateway.payment_gateway_mode_associations.build(payment_mode_id: @payment_mode.id)

          @payment_gateway_mode_association.payment_gateway_mode_association_ranges.build

          @payment_gateway_mode_association.payment_gateway_mode_association_tax_types.build

        end

      end
      
    rescue Exception => e

      message = e.message
      
    end

    if message.present?
      flash[:alert] = message
      redirect_back(fallback_location: proc { ccavenue_configs_path })
    end

  end

  private

  def ccavenue_config_params
    params.require(:ccavenue_config).permit(:alias_name, :working_key, :access_code, :merchant_id, :country_id, :tax_amount)
  end

  def set_payment_gateway_type
    @payment_gateway_type = PaymentGatewayType.find_by_config_model_name(controller_name.classify)
  end

  def set_ccavenue_config
    @ccavenue_config = CcavenueConfig.find(params[:id])
  end

  def set_payment_gateway
    @payment_gateway = @ccavenue_config.payment_gateway
  end

end
