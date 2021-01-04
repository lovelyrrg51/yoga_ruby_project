module Api::V1
  class AddressProofTypesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_address_proof_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
    # GET /address_proof_types
    def index
      @address_proof_types = policy_scope(AddressProofType)
      render json: @address_proof_types
    end
  
    # GET /address_proof_types/1
    def show
      render json: @address_proof_type
    end
  
    # GET /address_proof_types/new
    def new
      @address_proof_type = AddressProofType.new
    end
  
    # GET /address_proof_types/1/edit
    def edit
    end
  
    # POST /address_proof_types
    def create
      @address_proof_type = AddressProofType.new(address_proof_type_params)
      # authorize @address_proof_type
      if @address_proof_type.save
        render json: @address_proof_type
      else
        render json: @address_proof_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /address_proof_types/1
    def update
      # authorize @address_proof_type
      if @address_proof_type.update(address_proof_type_params)
        render json: @address_proof_type
      else
        render json: @address_proof_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /address_proof_types/1
    def destroy
      authorize @address_proof_type
      apt = @address_proof_type.destroy
      render json: apt
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_address_proof_type
        @address_proof_type = AddressProofType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def address_proof_type_params
        params.require(:address_proof_type).permit(:name)
      end
  end
end
