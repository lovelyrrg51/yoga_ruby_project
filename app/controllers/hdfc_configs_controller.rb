class HdfcConfigsController < ApplicationController

    before_action :set_payment_gateway_type, only:[:index, :create, :edit]
    before_action :set_hdfc_config, only:[:edit, :update, :destroy]
    before_action :authenticate_user!
  
    def index
  
      @hdfc_config = HdfcConfig.new
  
      authorize(@hdfc_config)
  
      @payment_gateway_type_name = @payment_gateway_type.name
  
      @hdfc_configs = HdfcConfig.page(params[:page]).per(params[:per_page])
  
    end

    def create

        begin
            
          @hdfc_config = @payment_gateway_type.payment_gateways.build.build_hdfc_config(hdfc_config_params)
    
          authorize(@hdfc_config)
    
          if @hdfc_config.save
            flash[:success] = "HDFC Configuration is successfully created."
          else
            flash[:error] = @hdfc_config.errors.full_messages.first
          end
    
          redirect_to hdfc_configs_path
          
        rescue Exception => e
    
          flash[:error] = e.message
          redirect_back(fallback_location: proc { root_path })
          
        end
    
      end
    
      def edit
    
        authorize(@hdfc_config)
    
        @payment_gateway_type_name = @payment_gateway_type.name
    
      end
    
      def update
    
        authorize(@hdfc_config)
    
        if @hdfc_config.update(hdfc_config_params)
          flash[:success] = "HDFC Configuration is successfully updated."
        else
          flash[:error] = @hdfc_config.errors.full_messages.first
        end
    
        redirect_to hdfc_configs_path
    
    
      end
    
      def destroy
    
        authorize(@hdfc_config)
    
        begin
    
          @hdfc_config.destroy!
          
        rescue Exception => e
          message = e.message
        end
    
        if message.present?
          flash[:error] = message
        else
          flash[:success] = "HDFC Configuration is successfully destroyed."
        end
    
        redirect_to hdfc_configs_path
    
      end
  
    private

    def set_payment_gateway_type
      @payment_gateway_type = PaymentGatewayType.find_by_config_model_name(controller_name.classify)
    end

    def hdfc_config_params
        params.require(:hdfc_config).permit(:alias_name, :working_key, :access_code, :merchant_id, :country_id, :tax_amount)
    end

    def set_hdfc_config
        @hdfc_config = HdfcConfig.find(params[:id])
    end
  
  end
  