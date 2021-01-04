module Api::V1
  class DashboardWidgetConfigsController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_dashboard_widget_config, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index]
  
    # GET /dashboard_widget_configs
    def index
      @dashboard_widget_configs = DashboardWidgetConfig.all
      render json: @dashboard_widget_configs
    end
  
    # GET /dashboard_widget_configs/1
    def show
    end
  
    # GET /dashboard_widget_configs/new
    def new
      @dashboard_widget_config = DashboardWidgetConfig.new
    end
  
    # GET /dashboard_widget_configs/1/edit
    def edit
    end
  
    # POST /dashboard_widget_configs
    def create
      @dashboard_widget_config = DashboardWidgetConfig.new(dashboard_widget_config_params)
      if @dashboard_widget_config.save
       render json: @dashboard_widget_config
      else
        render json: @dashboard_widget_config.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /dashboard_widget_configs/1
    def update
      if @dashboard_widget_config.update(dashboard_widget_config_params)
       render json: @dashboard_widget_config
      else
        render json: @dashboard_widget_config.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /dashboard_widget_configs/1
    def destroy
       dwc = @dashboard_widget_config.destroy
      render json: dwc
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_dashboard_widget_config
        @dashboard_widget_config = DashboardWidgetConfig.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def dashboard_widget_config_params
        params.require(:dashboard_widget_config).permit(:name, :is_visible, :widget)
      end
  end
end
