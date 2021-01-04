module Api::V1
  class SyEventCompaniesController < BaseController
    before_action :authenticate_user!, except: [:show]
    before_action :set_sy_event_company, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /sy_event_companies
    def index
      @sy_event_companies = SyEventCompany.all
      render json: @sy_event_companies
    end
  
    # GET /sy_event_companies/1
    def show
      render json: @sy_event_company
    end
  
    # GET /sy_event_companies/new
    def new
      render json: {}
    end
  
    # GET /sy_event_companies/1/edit
    def edit
    end
  
    # POST /sy_event_companies
    def create
      @sy_event_company = SyEventCompany.new(sy_event_company_params)
      authorize @sy_event_company
      if @sy_event_company.save
       render json: @sy_event_company
      else
        render json: @sy_event_company.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sy_event_companies/1
    def update
      authorize @sy_event_company
      if @sy_event_company.update(sy_event_company_params)
        render json: @sy_event_company
      else
        render json: @sy_event_company.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    # DELETE /sy_event_companies/1
    def destroy
      authorize @sy_event_company
      if @sy_event_company.update(is_deleted: true)
        render json: @sy_event_company
      else
        render json: @sy_event_company.errors.as_json(full_messages: true), status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_sy_event_company
        @sy_event_company = SyEventCompany.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def sy_event_company_params
        params.require(:sy_event_company).permit(:name, :llpin_number, :service_tax_number, :terms_and_conditions, :automatic_invoice)
      end
  end
end
