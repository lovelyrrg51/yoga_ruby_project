module Api::V1
  class ReportMasterFieldsController < BaseController
    before_action :authenticate_user!, except: []
    before_action :set_report_master_field, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /report_master_fields
    def index
      @report_master_fields = ReportMasterField.all
      render json: @report_master_fields
    end
  
    # GET /report_master_fields/1
    def show
      authorize @report_master_field
      render json: @report_master_field
    end
  
    # GET /report_master_fields/new
    def new
      @report_master_field = ReportMasterField.new
    end
  
    # GET /report_master_fields/1/edit
    def edit
    end
  
    # POST /report_master_fields
    def create
      @report_master_field = ReportMasterField.new(report_master_field_params)
      authorize @report_master_field
      if @report_master_field.save
        render json: @report_master_field
      else
        render json: @report_master_field.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /report_master_fields/1
    def update
      authorize @report_master_field
      if @report_master_field.update(report_master_field_params)
        render json: @report_master_field
      else
        render json: @report_master_field.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /report_master_fields/1
    def destroy
      authorize @report_master_field
      @report_master_field.destroy
      render json: @report_master_field
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_report_master_field
      @report_master_field = ReportMasterField.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def report_master_field_params
      params.require(:report_master_field).permit(:field_name)
    end
  end
end
