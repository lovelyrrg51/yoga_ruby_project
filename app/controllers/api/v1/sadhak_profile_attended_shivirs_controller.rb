module Api::V1
  class SadhakProfileAttendedShivirsController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_sadhak_profile_attended_shivir, only: [:show, :edit, :update, :destroy]
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    before_action :locate_collection, :only => :index
    respond_to :json
  
    # GET /sadhak_profile_attended_shivirs
    def index
      render json: @sadhak_profile_attended_shivirs
    end
  
    # GET /sadhak_profile_attended_shivirs/1
    def show
      authorize @sadhak_profile_attended_shivir
      render json: @sadhak_profile_attended_shivir
    end
  
    # GET /sadhak_profile_attended_shivirs/new
    def new
      @sadhak_profile_attended_shivir = SadhakProfileAttendedShivir.new
    end
  
    # GET /sadhak_profile_attended_shivirs/1/edit
    def edit
    end
  
    # POST /sadhak_profile_attended_shivirs
    def create
      @sadhak_profile_attended_shivir = SadhakProfileAttendedShivir.new(sadhak_profile_attended_shivir_params)
      # authorize @sadhak_profile_attended_shivir
      if @sadhak_profile_attended_shivir.save
        render json: @sadhak_profile_attended_shivir
      else
        render json: @sadhak_profile_attended_shivir.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /sadhak_profile_attended_shivirs/1
    def update
      # authorize @sadhak_profile_attended_shivir
      if @sadhak_profile_attended_shivir.update(sadhak_profile_attended_shivir_params)
        render json: @sadhak_profile_attended_shivir
      else
        render json: @sadhak_profile_attended_shivir.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /sadhak_profile_attended_shivirs/1
    def destroy
      # authorize @sadhak_profile_attended_shivir
      sadhak_profile_attended_shivir = @sadhak_profile_attended_shivir.destroy
      render json: sadhak_profile_attended_shivir
    end
  
    def locate_collection
      @sadhak_profile_attended_shivirs = SadhakProfileAttendedShivirPolicy::Scope.new(current_user, SadhakProfileAttendedShivir).resolve(filtering_params)
    end
  
    private
    # Use callbacks to share common setup or constraints between actions.
    def set_sadhak_profile_attended_shivir
      @sadhak_profile_attended_shivir = SadhakProfileAttendedShivir.find(params[:id])
    end
  
    # Never trust parameters from the scary internet, only allow the white list through.
    def sadhak_profile_attended_shivir_params
      params.require(:sadhak_profile_attended_shivir).permit(:shivir_name, :place, :month, :year, :sadhak_profile_id)
    end
  
    #filtering parameters
    def filtering_params
      params.slice(:sadhak_profile_id)
    end
  end
end
