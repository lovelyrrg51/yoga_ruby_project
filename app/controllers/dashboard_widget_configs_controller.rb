class DashboardWidgetConfigsController < ApplicationController

  before_action :set_dashboard_widget_config, only:[:edit, :update]
  before_action :authenticate_user!

  def index

    authorize DashboardWidgetConfig

    @dashboard_widget_configs = DashboardWidgetConfig.all

  end

  def edit

    authorize(@dashboard_widget_config)

  end

  def update

    authorize(@dashboard_widget_config)

    if @dashboard_widget_config.update(dashboard_widget_config_params)
      flash[:success] = "Dashboard Widget Config was successfully updated."
    else
      flash[:error] = @dashboard_widget_config.errors.full_messages.first
    end

    redirect_to dashboard_widget_configs_path

  end

  private

  def set_dashboard_widget_config 
    @dashboard_widget_config = DashboardWidgetConfig.find(params[:id])
  end

  def dashboard_widget_config_params
    params.require(:dashboard_widget_config).permit(:is_visible)
  end

end
