class SeatingCategoriesController < ApplicationController

  before_action :set_seating_category, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @seating_category = SeatingCategory.new

    authorize(@seating_category)

    if filtering_params.present?

      locate_collection

    else

      @seating_categories = @seating_categories = SeatingCategory.page(params[:page]).per(params[:per_page]).order('seating_categories.category_name ASC')

    end

  end

  def edit

    authorize(@seating_category)

  end

  def create

    @seating_category = SeatingCategory.new(seating_category_params)

    authorize(@seating_category)

    if @seating_category.save
      flash[:success] = "Seating Category was successfully created."
    else
      flash[:error] = @seating_category.errors.full_messages.first
    end

    redirect_to seating_categories_path

  end

  def update

    authorize(@seating_category)

    if @seating_category.update(seating_category_params)
      flash[:success] = "Seating Category was successfully updated."
    else
      flash[:error] = @seating_category.errors.full_messages.first
    end

    redirect_to seating_categories_path

  end


  def destroy

    authorize(@seating_category)

    if @seating_category.destroy
      flash[:success] = "Seating Category was successfully destroyed."
    else
      flash[:error] = @seating_category.errors.full_messages.first
    end
    
    redirect_to seating_categories_path

  end

  private

  def locate_collection

    @seating_categories = SeatingCategoryPolicy::Scope.new(current_user, SeatingCategory).resolve(filtering_params).order('seating_categories.category_name ASC').page(params[:page]).per(params[:per_page])

  end

  def set_seating_category
    @seating_category = SeatingCategory.find(params[:id])
  end

  def seating_category_params
      params.require(:seating_category).permit(:category_name)
  end

  def filtering_params
    params.slice(:seating_category_name)
  end

end
