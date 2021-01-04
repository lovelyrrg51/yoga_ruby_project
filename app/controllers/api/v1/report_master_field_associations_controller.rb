module Api::V1
  class ReportMasterFieldAssociationsController < BaseController
    before_action :authenticate_user!, except: []
    before_action :set_report_master_field_association, only: [:show, :edit, :update, :destroy]
    before_action :locate_collection, :only => :index
    skip_before_action :verify_authenticity_token, :only => []
    respond_to :json
  
    # GET /report_master_field_associations
    def index
      render json: @report_master_field_associations
    end
  
    # GET /report_master_field_associations/1
    def show
      authorize @report_master_field_association
      render json: @report_master_field_association
    end
  
    # GET /report_master_field_associations/new
    def new
      @report_master_field_association = ReportMasterFieldAssociation.new
    end
  
    # GET /report_master_field_associations/1/edit
    def edit
    end
  
    # POST /report_master_field_associations
    def create
      @report_master_field_association = ReportMasterFieldAssociation.new(report_master_field_association_params)
      authorize @report_master_field_association
      if @report_master_field_association.save
        render json: @report_master_field_association
      else
        render json: @report_master_field_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /report_master_field_associations/1
    def update
      authorize @report_master_field_association
      if @report_master_field_association.update(report_master_field_association_params)
        render json: @report_master_field_association
      else
        render json: @report_master_field_association.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /report_master_field_associations/1
    def destroy
      authorize @report_master_field_association
      @report_master_field_association.destroy
      render json: @report_master_field_association
    end
  
    def locate_collection
      @report_master_field_associations = ReportMasterFieldAssociationPolicy::Scope.new(current_user, ReportMasterFieldAssociation).resolve(filtering_params).includes(ReportMasterFieldAssociation.includable_data)
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_report_master_field_association
      @report_master_field_association = ReportMasterFieldAssociation.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def report_master_field_association_params
      params.require(:report_master_field_association).permit(:report_master_id, :report_master_field_id)
    end
  
    def filtering_params
      params.slice(:report_master_id, :report_master_field_id)
    end
  end
end
