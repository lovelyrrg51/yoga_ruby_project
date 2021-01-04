module Api::V1
  class MedicalPractitionerSpecialityAreasController < BaseController
    before_action :set_medical_practitioner_speciality_area, only: [:show, :edit, :update, :destroy]
  #   before_action :authenticate_user!
    respond_to :json
  
    # GET /medical_practitioner_speciality_areas
    def index
      @medical_practitioner_speciality_areas = MedicalPractitionerSpecialityArea.all
      render json: @medical_practitioner_speciality_areas
    end
  
    # GET /medical_practitioner_speciality_areas/1
    def show
    end
  
    # GET /medical_practitioner_speciality_areas/new
    def new
      @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.new
    end
  
    # GET /medical_practitioner_speciality_areas/1/edit
    def edit
    end
  
    # POST /medical_practitioner_speciality_areas
    def create
      @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.new(medical_practitioner_speciality_area_params)
      if @medical_practitioner_speciality_area.save
  #       render json: 'hiii'
  #       return false
        render json: @medical_practitioner_speciality_area
      else
        render json: @medical_practitioner_speciality_area.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /medical_practitioner_speciality_areas/1
    def update
      if @medical_practitioner_speciality_area.update(medical_practitioner_speciality_area_params)
        render json: @medical_practitioner_speciality_area
      else
        render json: @medical_practitioner_speciality_area.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /medical_practitioner_speciality_areas/1
    def destroy
     mpa =  @medical_practitioner_speciality_area.destroy
      render json: mpa
    end
  
    private
      # Use callbacks to share common setup or constraints between actions.
      def set_medical_practitioner_speciality_area
        @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.find(params[:id])
      end
  
      # Never trust parameters from the scary internet, only allow the white list through.
      def medical_practitioner_speciality_area_params
        params.require(:medical_practitioner_speciality_area).permit(:name)
      end
  end
end
