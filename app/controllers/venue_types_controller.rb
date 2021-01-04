class VenueTypesController < ApplicationController

  before_action :set_venue_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @venue_type = VenueType.new

    authorize(@venue_type)

    if filtering_params.present?

      locate_collection

    else

      @venue_types = VenueType.page(params[:page]).per(params[:per_page]).order('venue_types.name ASC')

    end

  end
  
  def edit

    authorize(@venue_type)

  end

  def create

    @venue_type = VenueType.new(venue_type_params)

    authorize(@venue_type)

    if @venue_type.save
      flash[:success] = "Venue Type was successfully created."
    else
      flash[:error] = @venue_type.errors.full_messages.first
    end

    redirect_to venue_types_path

  end

  def update

    authorize(@venue_type)

    if @venue_type.update(venue_type_params)
      flash[:success] = "Venue Type was successfully updated."
    else
      flash[:error] = @venue_type.errors.full_messages.first
    end

    redirect_to venue_types_path

  end


  def destroy

    authorize(@venue_type)

    if @venue_type.destroy
      flash[:success] = "Venue Type was successfully destroyed."
    else
      flash[:error] = @venue_type.errors.full_messages.first
    end

    redirect_to venue_types_path

  end

  private
  
  def locate_collection
    @venue_types = VenueTypePolicy::Scope.new(current_user, VenueType).resolve(filtering_params).order('venue_types.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_venue_type
    @venue_type = VenueType.find(params[:id])
  end

  def venue_type_params
      params.require(:venue_type).permit(:name,)
  end

  def filtering_params
    params.slice(:venue_type_name)
  end

end
