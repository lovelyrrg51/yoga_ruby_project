module Api::V1
  class TaxTypesController < BaseController
    before_action :authenticate_user!
    before_action :set_tax_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /tax_types
    def index
      @tax_types = policy_scope(TaxType)
      render json: @tax_types
    end
  
    # GET /tax_types/1
    def show
    end
  
    # GET /tax_types/new
    def new
      @tax_type = TaxType.new
    end
  
    # GET /tax_types/1/edit
    def edit
    end
  
    # POST /tax_types
    def create
      @tax_type = TaxType.new(tax_type_params)
      authorize @tax_type
      if @tax_type.save
        render json: @tax_type
      else
        render json: @tax_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /tax_types/1
    def update
      authorize @tax_type
      if @tax_type.update(tax_type_params)
        render json: @tax_type
      else
        render json: @tax_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /tax_types/1
    def destroy
      authorize @tax_type
      if @tax_type.update(is_deleted: true)
        render json: @tax_type
      else
        render json: @tax_type.errors, status: :unprocessable_entity
      end
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_tax_type
        @tax_type = TaxType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def tax_type_params
        params.require(:tax_type).permit(:name)
      end
  end
end
