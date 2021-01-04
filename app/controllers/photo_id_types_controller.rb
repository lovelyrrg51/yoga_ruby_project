class PhotoIdTypesController < ApplicationController

  before_action :set_photo_id_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @photo_id_type = PhotoIdType.new

    authorize(@photo_id_type)

    if filtering_params.present?

      locate_collection

    else

      @photo_id_types = PhotoIdType.page(params[:page]).per(params[:per_page]).order('photo_id_types.name ASC')

    end

  end

  def edit

    authorize(@photo_id_type)

  end

  def create

    @photo_id_type = PhotoIdType.new(photo_id_type_params)

    authorize(@photo_id_type)

    if @photo_id_type.save
      flash[:success] = "Photo Id Type was successfully created."
    else
      flash[:error] = @photo_id_type.errors.full_messages.first
    end

    redirect_to photo_id_types_path

  end

  def update

    authorize(@photo_id_type)

    if @photo_id_type.update(photo_id_type_params)
      flash[:success] = "Photo Id Type was successfully updated."
    else
      flash[:error] = @photo_id_type.errors.full_messages.first
    end

    redirect_to photo_id_types_path

  end


  def destroy

    authorize(@photo_id_type)

    if @photo_id_type.destroy
      flash[:success] = "Photo Id Type was successfully destroyed."
    else
      flash[:error] = @photo_id_type.errors.full_messages.first
    end

    redirect_to photo_id_types_path

  end

  private

  def locate_collection
    @photo_id_types = PhotoIdTypePolicy::Scope.new(current_user, PhotoIdType).resolve(filtering_params).order('photo_id_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_photo_id_type
    @photo_id_type = PhotoIdType.find(params[:id])
  end

  def photo_id_type_params
      params.require(:photo_id_type).permit(:name,)
  end

  def filtering_params
    params.slice(:photo_id_type_name)
  end

end
