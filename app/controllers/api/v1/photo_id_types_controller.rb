module Api::V1
  class PhotoIdTypesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_photo_id_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    # GET /photo_id_types
    def index
      @photo_id_types = policy_scope(PhotoIdType)
      render json: @photo_id_types
    end
  
    # GET /photo_id_types/1
    def show
      render json: @photo_id_type
    end
  
    # GET /photo_id_types/new
    def new
      @photo_id_type = PhotoIdType.new
    end
  
    # GET /photo_id_types/1/edit
    def edit
    end
  
    # POST /photo_id_types
    def create
      @photo_id_type = PhotoIdType.new(photo_id_type_params)
      # authorize @photo_id_type
      if @photo_id_type.save
        render json: @photo_id_type
      else
        render json: @photo_id_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /photo_id_types/1
    def update
      # authorize @photo_id_type
      if @photo_id_type.update(photo_id_type_params)
        render json: @photo_id_type
      else
        render json: @photo_id_type.errors, status: :unprocessable_entity
      end
  
    end
  
    # DELETE /photo_id_types/1
    def destroy
      authorize @photo_id_type
      pit = @photo_id_type.destroy
      render json: pit
  
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_photo_id_type
        @photo_id_type = PhotoIdType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def photo_id_type_params
        params.require(:photo_id_type).permit(:name)
      end
  end
end
