module Api::V1
  class ShivyogTeachingsController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_shivyog_teaching, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    # GET /shivyog_teachings
    def index
      @shivyog_teachings = policy_scope(ShivyogTeaching)
      render json: @shivyog_teachings
    end
  
    # GET /shivyog_teachings/1
    def show
      render json: @shivyog_teaching
    end
  
    # GET /shivyog_teachings/new
    def new
      @shivyog_teaching = ShivyogTeaching.new
    end
  
    # GET /shivyog_teachings/1/edit
    def edit
    end
  
    # POST /shivyog_teachings
    def create
      @shivyog_teaching = ShivyogTeaching.new(shivyog_teaching_params)
      # authorize @shivyog_teaching
      if @shivyog_teaching.save
        render json: @shivyog_teaching
      else
        render json: @shivyog_teaching.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /shivyog_teachings/1
    def update
      # authorize @shivyog_teaching
      if @shivyog_teaching.update(shivyog_teaching_params)
        render json: @shivyog_teaching
      else
        render json: @shivyog_teaching.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /shivyog_teachings/1
    def destroy
      authorize @shivyog_teaching
      res = @shivyog_teaching.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_shivyog_teaching
        @shivyog_teaching = ShivyogTeaching.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def shivyog_teaching_params
        params.require(:shivyog_teaching).permit(:name)
      end
  end
end
