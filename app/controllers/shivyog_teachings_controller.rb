class ShivyogTeachingsController < ApplicationController

  before_action :set_shivyog_teaching, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @shivyog_teaching = ShivyogTeaching.new

    authorize(@shivyog_teaching)

    if filtering_params.present?

      locate_collection

    else

    @shivyog_teachings = ShivyogTeaching.page(params[:page]).per(params[:per_page]).order('shivyog_teachings.name ASC')

    end

  end

  def edit

    authorize(@shivyog_teaching)

  end

  def create

    @shivyog_teaching = ShivyogTeaching.new(shivyog_teaching_params)

    authorize(@shivyog_teaching)

    if @shivyog_teaching.save

      flash[:success] = "Shivyog Teaching was successfully created."
    else
      flash[:error] = @shivyog_teaching.errors.full_messages.first
    end

    redirect_to shivyog_teachings_path

  end

  def update

    authorize(@shivyog_teaching)

    if @shivyog_teaching.update(shivyog_teaching_params)
      flash[:success] = "Shivyog Teaching was successfully updated."
    else
      flash[:error] = @shivyog_teaching.errors.full_messages.first    
    end

    redirect_to shivyog_teachings_path

  end


  def destroy

    authorize(@shivyog_teaching)

    if @shivyog_teaching.destroy
      flash[:success] = "Shivyog Teaching was successfully destroyed."
    else
      flash[:error] = @shivyog_teaching.errors.full_messages.first    
    end

    redirect_to shivyog_teachings_path

  end

  private

  def locate_collection
    @shivyog_teachings = ShivyogTeachingPolicy::Scope.new(current_user, ShivyogTeaching).resolve(filtering_params).order('shivyog_teachings.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_shivyog_teaching
    @shivyog_teaching = ShivyogTeaching.find(params[:id])
  end

  def shivyog_teaching_params
      params.require(:shivyog_teaching).permit(:name)
  end

  def filtering_params
    params.slice(:shivyog_teaching_name)
  end

end