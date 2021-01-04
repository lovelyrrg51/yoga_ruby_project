module Api::V1
  class PhysicalExerciseTypesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_physical_exercise_type, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
  
    # GET /physical_exercise_types
    def index
      @physical_exercise_types = policy_scope(PhysicalExerciseType)
      render json: @physical_exercise_types
    end
  
    # GET /physical_exercise_types/1
    def show
      render json: @physical_exercise_type
    end
  
    # GET /physical_exercise_types/new
    def new
      @physical_exercise_type = PhysicalExerciseType.new
    end
  
    # GET /physical_exercise_types/1/edit
    def edit
    end
  
    # POST /physical_exercise_types
    def create
      @physical_exercise_type = PhysicalExerciseType.new(physical_exercise_type_params)
      authorize @physical_exercise_type
      if @physical_exercise_type.save
        render json: @physical_exercise_type
      else
        render json: @physical_exercise_type.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /physical_exercise_types/1
    def update
      authorize @physical_exercise_type
      if @physical_exercise_type.update(physical_exercise_type_params)
        render json: @physical_exercise_type
      else
        render json: @physical_exercise_type.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /physical_exercise_types/1
    def destroy
      res = @physical_exercise_type.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_physical_exercise_type
        @physical_exercise_type = PhysicalExerciseType.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def physical_exercise_type_params
        params.require(:physical_exercise_type).permit(:name)
      end
  end
end
