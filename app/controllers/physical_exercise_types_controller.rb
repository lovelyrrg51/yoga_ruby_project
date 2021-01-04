class PhysicalExerciseTypesController < ApplicationController

  before_action :set_physical_exercise_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @physical_exercise_type = PhysicalExerciseType.new

    authorize(@physical_exercise_type)

    if filtering_params.present?

      locate_collection

    else

    @physical_exercise_types = PhysicalExerciseType.page(params[:page]).per(params[:per_page]).order('physical_exercise_types.name ASC')

    end

  end

  def edit

    authorize(@physical_exercise_type)

  end

  def create

    @physical_exercise_type = PhysicalExerciseType.new(physical_exercise_type_params)

    authorize(@physical_exercise_type)

    if @physical_exercise_type.save

      flash[:success] = "Physical Exercise was successfully created."
    else
      flash[:error] = @physical_exercise_type.errors.full_messages.first
    end

    redirect_to physical_exercise_types_path

  end

  def update

    authorize(@physical_exercise_type)

    if @physical_exercise_type.update(physical_exercise_type_params)
      flash[:success] = "Physical Exercise was successfully updated."
    else
      flash[:error] = @physical_exercise_type.errors.full_messages.first
    end

    redirect_to physical_exercise_types_path

  end


  def destroy

    authorize(@physical_exercise_type)

    if @physical_exercise_type.destroy
      flash[:success] = "Physical Exercise was successfully destroyed."
    else
      flash[:error] = @physical_exercise_type.errors.full_messages.first
    end

    redirect_to physical_exercise_types_path

  end

  private

  def locate_collection
    @physical_exercise_types = PhysicalExerciseTypePolicy::Scope.new(current_user, PhysicalExerciseType).resolve(filtering_params).order('physical_exercise_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_physical_exercise_type
    @physical_exercise_type = PhysicalExerciseType.find(params[:id])
  end

  def physical_exercise_type_params
      params.require(:physical_exercise_type).permit(:name)
  end

  def filtering_params
    params.slice(:physical_exercise_type_name)
  end

end
