class EventCancellationPlanItemsController < ApplicationController
  before_action :locate_collection, only: [:find_plan_items]
  before_action :set_event_cancellation_plan, only:[:new, :edit, :create, :update, :destroy, :index]
  before_action :set_event_cancellation_plan_item, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @event_cancellation_plan_item = EventCancellationPlanItem.new

    authorize(@event_cancellation_plan_item)

    @event_cancellation_plan_items = EventCancellationPlanItem.where(event_cancellation_plan_id: params[:event_cancellation_plan_id]).page(params[:page]).per(params[:per_page])

  end

  def find_plan_items
    @is_params_blank = true unless params[:event_cancellation_plan_id].present?
  	respond_to do |format|
      format.js
    end
  end

  def create

    begin

      @event_cancellation_plan_item = @event_cancellation_plan.event_cancellation_plan_items.new(event_cancellation_plan_item_params)

      authorize(@event_cancellation_plan_item)

      if @event_cancellation_plan_item.save
        flash[:success] = "Event Cancellation Plan was successfully created."
      else
        flash[:error] = @event_cancellation_plan_item.errors.full_messages.first
      end

      redirect_to event_cancellation_plan_event_cancellation_plan_items_path(@event_cancellation_plan)
      
    rescue Exception => e

      flash[:error] = e.message
      redirect_back(fallback_location: proc { root_path })
      
    end

  end

  def edit

    authorize(@event_cancellation_plan_item)

  end

  def update
    
    authorize(@event_cancellation_plan_item)

    if @event_cancellation_plan_item.update(event_cancellation_plan_item_params)
      flash[:success] = "Event Cancellation Plan was successfully updated."
    else
      flash[:error] = @event_cancellation_plan_item.errors.full_messages.first
    end

    redirect_to event_cancellation_plan_event_cancellation_plan_items_path(@event_cancellation_plan)
  end


  def destroy

    authorize(@event_cancellation_plan_item)

    if @event_cancellation_plan_item.destroy
      flash[:success] = "Event Cancellation Plan was successfully destroyed."
    else
      flash[:error] = @event_cancellation_plan_item.errors.full_messages.first
    end
    
    redirect_to event_cancellation_plan_event_cancellation_plan_items_path(@event_cancellation_plan)
  end

  private

  def locate_collection
    @event_cancellation_plan_items = EventCancellationPlanItemPolicy::Scope.new(current_user, EventCancellationPlanItem).resolve(filtering_params)
  end

  def set_event_cancellation_plan
    @event_cancellation_plan = EventCancellationPlan.find(params[:event_cancellation_plan_id])
  end

  def set_event_cancellation_plan_item
    @event_cancellation_plan_item = EventCancellationPlanItem.find(params[:id])
  end

  def event_cancellation_plan_item_params
      params.require(:event_cancellation_plan_item).permit(:days_before, :amount, :amount_type)
  end

  def filtering_params
      params.slice(:event_cancellation_plan_id)
  end

end
