class SourceInfoTypesController < ApplicationController   

  before_action :set_source_info_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @source_info_type = SourceInfoType.new

    authorize(@source_info_type)

    if filtering_params.present?

      locate_collection

    else

      @source_info_types = SourceInfoType.page(params[:page]).per(params[:per_page]).order('source_info_types.source_name ASC')

    end

  end

  def create

    @source_info_type = SourceInfoType.new(source_info_type_params)

    authorize(@source_info_type)

    if @source_info_type.save
      flash[:success] = "Source Information Type was successfully created."
    else
      flash[:error] = @source_info_type.errors.full_messages.first
    end

    redirect_to source_info_types_path

  end

   def edit

    authorize(@source_info_type)

  end

  def update
    
    authorize(@source_info_type)

    if @source_info_type.update(source_info_type_params)
      flash[:success] = "Source Information Type was successfully updated."
    else
      flash[:error] = @source_info_type.errors.full_messages.first
    end

    redirect_to source_info_types_path

  end


  def destroy

    authorize(@source_info_type)

    if @source_info_type.destroy
      flash[:success] = "Source Information Type was successfully destroyed."
    else
      flash[:error] = @source_info_type.errors.full_messages.first
    end
    
    redirect_to source_info_types_path

  end

  private

  def locate_collection
    @source_info_types = SourceInfoTypePolicy::Scope.new(current_user, SourceInfoType).resolve(filtering_params).order('source_info_types.source_name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_source_info_type
    @source_info_type = SourceInfoType.find(params[:id])
  end

  def source_info_type_params
      params.require(:source_info_type).permit(:source_name)
  end

  def filtering_params
    params.slice(:source_info_type_name)
  end
end
