module Api::V1
  class ProfessionsController < BaseController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :set_profession, only: [:show, :edit, :update, :destroy]
    respond_to :json
    # GET /professions
    def index
      @professions = policy_scope(Profession)
      render json: @professions
    end
  
    # GET /professions/1
    def show
      render json: @profession
    end
  
    # GET /professions/new
    def new
      @profession = Profession.new
    end
  
    # GET /professions/1/edit
    def edit
    end
  
    # POST /professions
    def create
      @profession = Profession.new(profession_params)
      # authorize @profession
      if @profession.save
        render json: @profession
      else
        render json: @profession.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /professions/1
    # PATCH/PUT /professions/1.json
    def update
      authorize @profession
      if @profession.update(profession_params)
        render json: @profession
      else
        render json: @profession.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /professions/1
    def destroy
      authorize @profession
      res = @profession.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_profession
        @profession = Profession.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def profession_params
        params.require(:profession).permit(:name)
      end
  end
end
