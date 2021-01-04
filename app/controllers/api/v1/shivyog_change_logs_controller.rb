module Api::V1
  class ShivyogChangeLogsController < BaseController
    before_action :authenticate_user!, except: [:index]
    before_action :set_shivyog_change_log, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    respond_to :json
  
    # GET /shivyog_change_logs
    def index
      # @shivyog_change_logs = policy_scope(ShivyogChangeLog);
      render json: @shivyog_change_logs
    end
  
    # GET /shivyog_change_logs/1
    def show
      render json: @shivyog_change_log
    end
  
    # GET /shivyog_change_logs/new
    def new
      @shivyog_change_log = ShivyogChangeLog.new
    end
  
    # GET /shivyog_change_logs/1/edit
    def edit
    end
  
    # POST /shivyog_change_logs
    def create
      @shivyog_change_log = ShivyogChangeLog.new(shivyog_change_log_params)
      authorize @shivyog_change_log
      if @shivyog_change_log.save
        render json: @shivyog_change_log
      else
        render json: @shivyog_change_log.errors, status: unprocessable_entity
      end
    end
  
    # PATCH/PUT /shivyog_change_logs/1
    def update
      authorize @shivyog_change_log
      if @shivyog_change_log.update(shivyog_change_log_params)
        render json: @shivyog_change_log
      else
        render json: @shivyog_change_log.errors, status: unprocessable_entity
      end
    end
  
    # DELETE /shivyog_change_logs/1
    def destroy
      authorize @shivyog_change_log
      sgcl = @shivyog_change_log.destroy
      render json: sgcl
    end
  
    def locate_collection
      @shivyog_change_logs = ShivyogChangeLogPolicy::Scope.new(current_user, ShivyogChangeLog.order(:id)).resolve(filtering_params)
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_shivyog_change_log
        @shivyog_change_log = ShivyogChangeLog.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def shivyog_change_log_params
        params.require(:shivyog_change_log).permit(:attribute_name, :value_before, :value_after, :description, :change_loggable_id, :change_loggable_type)
      end
  
      def filtering_params
        params.slice(:change_loggable_id, :change_loggable_type, :attribute_name)
     end
  end
end
