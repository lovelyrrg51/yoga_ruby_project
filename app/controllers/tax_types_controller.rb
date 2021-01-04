class TaxTypesController < ApplicationController

  before_action :set_tax_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @tax_type = TaxType.new

    authorize(@tax_type)

    if filtering_params.present?
      locate_collection
    else
      @tax_types = TaxType.page(params[:page]).per(params[:per_page]).order('tax_types.name ASC')
    end

  end

  def edit

    authorize(@tax_type)

  end

  def create

    @tax_type = TaxType.new(tax_type_params)

    authorize(@tax_type)

    if @tax_type.save
      flash[:success] = "Tax Type was successfully created."
    else
      flash[:error] = @tax_type.errors.full_messages.first
    end

    redirect_to tax_types_path

  end

  def update

    authorize(@tax_type)

    if @tax_type.update(tax_type_params)
      flash[:success] = "Tax Type was successfully updated."
    else
      flash[:error] = @tax_type.errors.full_messages.first
    end

    redirect_to tax_types_path

  end


  def destroy

    authorize(@tax_type)

    if @tax_type.destroy
      flash[:success] = "Tax Type was successfully destroyed."
    else
      flash[:error] = @tax_type.errors.full_messages.first
    end
    
    redirect_to tax_types_path

  end

  private

  def locate_collection
    @tax_types = TaxTypePolicy::Scope.new(current_user, TaxType).resolve(filtering_params).order('tax_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_tax_type
    @tax_type = TaxType.find(params[:id])
  end

  def tax_type_params
      params.require(:tax_type).permit(:name)
  end

  def filtering_params
    params.slice(:tax_type_name)
  end

end
