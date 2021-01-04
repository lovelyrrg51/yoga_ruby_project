class SubSourceTypesController < ApplicationController

  before_action :set_source_info_type, only:[:new, :edit, :create, :update, :destroy, :index]
  before_action :set_sub_source_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:get_sub_source_type]

  def index

    @sub_source_type = SubSourceType.new

    authorize(@sub_source_type)

    @sub_source_types = SubSourceType.where(source_info_type_id: params[:source_info_type_id]).page(params[:page]).per(params[:per_page])

  end

  def edit

    authorize(@sub_source_type)

  end

  def create

    begin

      @sub_source_type = @source_info_type.sub_source_types.new(sub_source_type_params)

      authorize(@sub_source_type)

      if @sub_source_type.save
        flash[:success] = "Event Cancellation Plan was successfully created."
      else
        flash[:error] = @sub_source_type.errors.full_messages.first
      end

      redirect_to source_info_type_sub_source_types_path(@source_info_type)
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def update
    
    authorize(@sub_source_type)

    if @sub_source_type.update(sub_source_type_params)
      flash[:success] = "Event Cancellation Plan was successfully updated."
    else
      flash[:error] = @sub_source_type.errors.full_messages.first
    end

    redirect_to source_info_type_sub_source_types_path(@source_info_type)
  end


  def destroy

    authorize(@sub_source_type)

    if @sub_source_type.destroy
      flash[:success] = "Event Cancellation Plan was successfully destroyed."
    else
      flash[:error] = @sub_source_type.errors.full_messages.first
    end
    
    redirect_to source_info_type_sub_source_types_path(@source_info_type)
  end

  def get_sub_source_type
    
    @sub_sources = SubSourceType.where(source_info_type_id: params[:source_info_type_id]) if params[:source_info_type_id].present?

    respond_to do |format|
      format.js
    end

  end

  private

  def set_source_info_type
    @source_info_type = SourceInfoType.find(params[:source_info_type_id])
  end

  def set_sub_source_type
    @sub_source_type = SubSourceType.find(params[:id])
  end

  def sub_source_type_params
      params.require(:sub_source_type).permit(:sub_source_name)
  end
  
end
