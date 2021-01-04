module Api::V1
  class AspectsOfLivesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_aspects_of_life, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
  
    # GET /aspects_of_lives
    def index
      @aspects_of_lives = policy_scope(AspectsOfLife)
    end
  
    # GET /aspects_of_lives/1
    def show
      authorize @aspects_of_life
      render json: @aspects_of_life
    end
  
    # GET /aspects_of_lives/new
    def new
      @aspects_of_life = AspectsOfLife.new
    end
  
    # GET /aspects_of_lives/1/edit
    def edit
    end
  
    # POST /aspects_of_lives
    # POST /aspects_of_lives.json
    def create
      @aspects_of_life = AspectsOfLife.new(aspects_of_life_params)
      # authorize @aspects_of_life
      if @aspects_of_life.save
        render json: @aspects_of_life
      else
        render json: @aspects_of_life.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /aspects_of_lives/1
    def update
      # authorize @aspects_of_life
      if @aspects_of_life.update(aspects_of_life_params)
        render json: @aspects_of_life
      else
        render json: @aspects_of_life.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /aspects_of_lives/1
    def destroy
      authorize @aspects_of_life
      res = @aspects_of_life.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_aspects_of_life
        @aspects_of_life = AspectsOfLife.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def aspects_of_life_params
        params.require(:aspects_of_life).permit(:sadhak_profile_id)
      end
  end
end
