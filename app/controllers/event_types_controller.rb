class EventTypesController < ApplicationController

  before_action :set_event_type, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @event_type = EventType.new

    authorize(@event_type)

    if filtering_params.present?

      locate_collection

    else

      @event_types = EventType.page(params[:page]).per(params[:per_page]).order('event_types.name ASC')

    end

  end

  def edit

    authorize(@event_type)

  end

  def create

    @event_type = EventType.new(event_type_params)

    authorize(@event_type)

    if @event_type.save
      flash[:success] = "Event type was successfully created."
    else
      flash[:error] = @event_type.errors.full_messages.first
    end

    redirect_to event_types_path

  end

  def update

    authorize(@event_type)

    if @event_type.update(event_type_params)
      flash[:success] = "Event type was successfully updated."
    else
      flash[:error] = @event_type.errors.full_messages.first
    end

    redirect_to event_types_path

  end


  def destroy

    authorize(@event_type)

    if @event_type.destroy
      flash[:success] = "Event type was successfully destroyed."
    else
      flash[:error] = @event_type.errors.full_messages.first
    end
    
    redirect_to event_types_path

  end

  private

  def locate_collection
    @event_types = EventTypePolicy::Scope.new(current_user, EventType).resolve(filtering_params).order('event_types.name ASC').page(params[:page]).per(params[:per_page])
  end


  def set_event_type
    @event_type = EventType.find(params[:id])
  end

  def event_type_params
    params.require(:event_type).permit(:name, :event_meta_type)
  end

  def filtering_params
    params.slice(:event_type_name)
  end

end
