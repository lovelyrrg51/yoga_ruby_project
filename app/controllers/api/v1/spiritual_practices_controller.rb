module Api::V1
  class SpiritualPracticesController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create]
    before_action :set_spiritual_practice, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create]
  
    # GET /spiritual_practices
    def index
      @spiritual_practices = policy_scope(SpiritualPractice)
      render json: @spiritual_practices
    end
  
    # GET /spiritual_practices/1
    def show
      authorize @spiritual_practice
      render json: @spiritual_practice
    end
  
    # GET /spiritual_practices/new
    def new
      @spiritual_practice = SpiritualPractice.new
    end
  
    # GET /spiritual_practices/1/edit
    def edit
    end
  
    # POST /spiritual_practices
    def create
      @spiritual_practice = SpiritualPractice.new(spiritual_practice_params)
      # authorize @spiritual_practice
      if @spiritual_practice.save
        render json: @spiritual_practice
      else
        render json: @spiritual_practice.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /spiritual_practices/1
    def update
      # authorize @spiritual_practice
      if @spiritual_practice.update(spiritual_practice_params)
        render json: @spiritual_practice
      else
        render json: @spiritual_practice.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /spiritual_practices/1
    def destroy
      authorize @spiritual_practice
      res = @spiritual_practice.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_spiritual_practice
        @spiritual_practice = SpiritualPractice.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def spiritual_practice_params
        params.require(:spiritual_practice).permit(:morning_sadha_duration_hours, :afternoon_sadha_duration_hours, :evening_sadha_duration_hours, :other_sadha_duration_hours, :sadhana_frequency_days_per_week, :frequency_period, :frequency_type, :frequent_sadhana_type, :physical_exercise_type, :shivyog_teachings_applied_in_life, :sadhak_profile_id, :frequent_sadhna_type_ids => [], :physical_exercise_type_ids => [], :shivyog_teaching_ids => [])
      end
  end
end
