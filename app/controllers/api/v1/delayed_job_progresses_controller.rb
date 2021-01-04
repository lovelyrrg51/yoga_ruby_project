module Api::V1
  class DelayedJobProgressesController < BaseController
  
    before_action :authenticate_user!, except: []
    skip_before_action :verify_authenticity_token, only: []
    before_action :set_delayed_job_progress, only: [:show]
  
    def show
  
      render json: @delayed_job_progress
  
    end
  
    private
  
    def set_delayed_job_progress
  
      @delayed_job_progress = DelayedJobProgress.with_deleted.find(params[:job_id])
  
    end
  
  end
end
