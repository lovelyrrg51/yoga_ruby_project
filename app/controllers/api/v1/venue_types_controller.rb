module Api::V1
  class VenueTypesController < BaseController
    before_action :authenticate_user!
    before_action :set_venue_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    # GET /venue_types
    def index
      @venue_types = policy_scope(VenueType)
      render json: @venue_types
    end
  
    # GET /venue_types/1
    def show
    end
  
    # GET /venue_types/new
    def new
      @venue_type = VenueType.new
    end
  
    # GET /venue_types/1/edit
    def edit
    end
  
    # POST /venue_types
    def create
      @venue_type = VenueType.new(venue_type_params)
      if @venue_type.save
        render json: @venue_type
      else
        render json: @venue_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /venue_types/1
    def update
      if @venue_type.update(venue_type_params)
        render json: @venue_type
      else
        render json: @venue_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /venue_types/1
    def destroy
      vt = @venue_type.destroy
      render json: vt
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_venue_type
        @venue_type = VenueType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def venue_type_params
        params.require(:venue_type).permit(:name)
      end
  end
end
