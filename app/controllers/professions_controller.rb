class ProfessionsController < ApplicationController

  before_action :set_profession, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @profession = Profession.new

    authorize(@profession)

    if filtering_params.present?

      locate_collection

    else

      @professions = Profession.page(params[:page]).per(params[:per_page]).order('professions.name ASC')

    end

  end

  def edit

    authorize(@profession)

  end

  def create

    @profession = Profession.new(profession_params)

    authorize(@profession)

    if @profession.save

      flash[:success] = "Profession was successfully created."
    else
      flash[:error] = @profession.errors.full_messages.first
    end

    redirect_to professions_path

  end

  def update

    authorize(@profession)

    if @profession.update(profession_params)
      flash[:success] = "Profession was successfully updated."
    else
      flash[:error] = @profession.errors.full_messages.first
    end

    redirect_to professions_path

  end


  def destroy

    authorize(@profession)

    if @profession.destroy
      flash[:success] = "Profession was successfully destroyed."
    else
      flash[:error] = @profession.errors.full_messages.first
    end

    redirect_to professions_path

  end

  private

  def locate_collection
    @professions = ProfessionPolicy::Scope.new(current_user, Profession).resolve(filtering_params).order('professions.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_profession
    @profession = Profession.find(params[:id])
  end

  def profession_params
      params.require(:profession).permit(:name)
  end

  def filtering_params
    params.slice(:profession_name)
  end

end
