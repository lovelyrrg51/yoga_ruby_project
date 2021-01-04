module Api::V1
  class ProfessionalDetailsController < BaseController
    before_action :authenticate_user!, except: [:index, :show, :create, :update]
    before_action :set_professional_detail, only: [:show, :edit, :update, :destroy]
    respond_to :json
    skip_before_action :verify_authenticity_token, :only => [:index, :create, :update]
    # GET /professional_details
    def index
      @professional_details = policy_scope(ProfessionalDetail)
      render json: @professional_details
    end
  
    # GET /professional_details/1
    def show
      authorize @professional_detail
      render json: @professional_detail
    end
  
    # GET /professional_details/new
    def new
      @professional_detail = ProfessionalDetail.new
    end
  
    # GET /professional_details/1/edit
    def edit
    end
  
    # POST /professional_details
    def create
      @professional_detail = ProfessionalDetail.new(professional_detail_params)
      # authorize @professional_detail
      if @professional_detail.save
        render json: @professional_detail
      else
        render json: @professional_detail.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /professional_details/1
    def update
      # authorize @professional_detail
      if @professional_detail.update(professional_detail_params)
        render json: @professional_detail
      else
        render json: @professional_detail.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /professional_details/1
    def destroy
      authorize @professional_detail
      res = @professional_detail.destroy
      render json: res
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_professional_detail
        @professional_detail = ProfessionalDetail.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def professional_detail_params
        params.require(:professional_detail).permit(:occupation, :professional_specialization, :highest_degree, :designation, :industry, :profession_id, :area_of_specialization, :other_profession, :name_of_organization, :years_of_experience, :personal_interests, :hobbies, :sadhak_profile_id)
      end
  end
end
