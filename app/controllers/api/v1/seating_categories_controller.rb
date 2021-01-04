module Api::V1
  class SeatingCategoriesController < BaseController
    before_action :authenticate_user!, :except => [:index]
    before_action :set_seating_category, only: [:show, :edit, :update, :destroy]
    respond_to :json
  
    def index
      @seating_categories = SeatingCategory.all.order(:category_name)
      render json: @seating_categories
    end
  
    def show
      authorize @seating_category
      render json: @seating_category
    end
  
    def new
      @seating_category = SeatingCategory.new
    end
  
    def edit
      @seating_category.update(seating_category_parms)
    end
  
    def create
      @seating_category = SeatingCategory.new(seating_category_parms)
      authorize @seating_category
  
      if @seating_category.save
        render json: @seating_category
      else
        render json: @seating_category.errors, status: :unprocessable_entity
      end
    end
  
    def update
      authorize @seating_category
  
      if @seating_category.update(seating_category_parms)
        render json: @seating_category
      else
        render json: @seating_category.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /seating_categories/1
    # DELETE /seating_categories/1.json
    def destroy
      authorize @seating_category
      res = @seating_category.delete
      render json: res
    end
  
    private
  
      # Never trust parameters from the scary internet, only allow the white list through.
    def seating_category_parms
      params.require(:seating_category).permit(:category_name)
    end
  
    def set_seating_category
      @seating_category = SeatingCategory.find(params[:id])
    end
  
  end
end
