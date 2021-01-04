class Chrome::Api::V2::ChromeLogsController < Chrome::Api::V2::BaseController

    def create
        begin
            raise "Invalid User." unless current_user.present?
            ChromeLog.create(chrome_log_params.merge({ ip_address: request.remote_ip }))
        rescue Exception => e
            @error_msg = e.message
        ensure
            if @error_msg.present?
                render json: @error_msg, status: :unauthorized
            else
                head :ok
            end
        end
    end

    private
  
    def chrome_log_params
      params.require(:chrome_log).permit(:user_id, :asset_id, :status, :data, :date_time)
    end
  end
  