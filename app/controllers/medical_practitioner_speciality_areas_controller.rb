class MedicalPractitionerSpecialityAreasController < ApplicationController

  before_action :set_medical_practitioner_speciality_area, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.new

    authorize(@medical_practitioner_speciality_area)

    if filtering_params.present?

      locate_collection

    else

      @medical_practitioner_speciality_areas = MedicalPractitionerSpecialityArea.page(params[:page]).per(params[:per_page]).order('medical_practitioner_speciality_areas.name ASC')

    end

  end

  def edit

    authorize(@medical_practitioner_speciality_area)

  end

  def create

    @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.new(medical_practitioner_speciality_area_params)

    authorize(@medical_practitioner_speciality_area)

    if @medical_practitioner_speciality_area.save
      flash[:success] = "Medical Practitioner Speciality Area was successfully created."
    else
      flash[:error] = @medical_practitioner_speciality_area.errors.full_messages.first
    end

    redirect_to medical_practitioner_speciality_areas_path

  end

  def update

    authorize(@medical_practitioner_speciality_area)

    if @medical_practitioner_speciality_area.update(medical_practitioner_speciality_area_params)
      flash[:success] = "Medical Practitioner Speciality Area was successfully updated."
    else
      flash[:error] = @medical_practitioner_speciality_area.errors.full_messages.first
    end

    redirect_to medical_practitioner_speciality_areas_path

  end


  def destroy

    authorize(@medical_practitioner_speciality_area)

    if @medical_practitioner_speciality_area.destroy
      flash[:success] = "Medical Practitioner Speciality Area was successfully destroyed."
    else
      flash[:error] = @medical_practitioner_speciality_area.errors.full_messages.first
    end

    redirect_to medical_practitioner_speciality_areas_path

  end

  private

  def locate_collection
    @medical_practitioner_speciality_areas = MedicalPractitionerSpecialityAreaPolicy::Scope.new(current_user, MedicalPractitionerSpecialityArea).resolve(filtering_params).order('medical_practitioner_speciality_areas.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_medical_practitioner_speciality_area
    @medical_practitioner_speciality_area = MedicalPractitionerSpecialityArea.find(params[:id])
  end

  def medical_practitioner_speciality_area_params
      params.require(:medical_practitioner_speciality_area).permit(:name,)
  end

  def filtering_params
    params.slice(:medical_practitioner_speciality_area_name)
  end

end