class FrequentSadhnaTypesController < ApplicationController

  before_action :set_frequent_sadhna_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @frequent_sadhna_type = FrequentSadhnaType.new

    authorize(@frequent_sadhna_type)

    if filtering_params.present?

      locate_collection

    else

    @frequent_sadhna_types = FrequentSadhnaType.page(params[:page]).per(params[:per_page]).order('frequent_sadhna_types.name ASC')

    end

  end

  def edit

    authorize(@frequent_sadhna_type)

  end

  def create

    @frequent_sadhna_type = FrequentSadhnaType.new(frequent_sadhna_type_params)

    authorize(@frequent_sadhna_type)

    if @frequent_sadhna_type.save
      flash[:success] = "Sadhna Type was successfully created."
    else
      flash[:error] = @frequent_sadhna_type.errors.full_messages.first
    end

    redirect_to frequent_sadhna_types_path

  end

  def update

    authorize(@frequent_sadhna_type)

    if @frequent_sadhna_type.update(frequent_sadhna_type_params)
      flash[:success] = "Sadhna Type was successfully updated."
    else
      flash[:error] = @frequent_sadhna_type.errors.full_messages.first
    end

    redirect_to frequent_sadhna_types_path

  end


  def destroy

    authorize(@frequent_sadhna_type)

    if @frequent_sadhna_type.destroy
      flash[:success] = "Sadhna Type was successfully destroyed."
    else
      flash[:error] = @frequent_sadhna_type.errors.full_messages.first
    end

    redirect_to frequent_sadhna_types_path

  end

  private

  def locate_collection
    @frequent_sadhna_types = FrequentSadhnaTypePolicy::Scope.new(current_user, FrequentSadhnaType).resolve(filtering_params).order('frequent_sadhna_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_frequent_sadhna_type
    @frequent_sadhna_type = FrequentSadhnaType.find(params[:id])
  end

  def frequent_sadhna_type_params
      params.require(:frequent_sadhna_type).permit(:name)
  end

  def filtering_params
    params.slice(:sadhna_name)
  end

end
