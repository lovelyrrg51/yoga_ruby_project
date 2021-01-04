class EventCancellationPlansController < ApplicationController  

  before_action :set_event_cancellation_plan, only:[:edit, :update, :destroy]
  before_action :authenticate_user!

  def index

    @event_cancellation_plan = EventCancellationPlan.new

    authorize(@event_cancellation_plan)

    if filtering_params.present?
      locate_collection
    else
      @event_cancellation_plans = EventCancellationPlan.page(params[:page]).per(params[:per_page]).order('event_cancellation_plans.name ASC')
    end

  end

  def edit

    authorize(@event_cancellation_plan)

  end

  def create

    @event_cancellation_plan = EventCancellationPlan.new(event_cancellation_plan_params)

    authorize(@event_cancellation_plan)

    if @event_cancellation_plan.save
      flash[:success] = "Event Cancellation Plan was successfully created."
    else
      flash[:error] = @event_cancellation_plan.errors.full_messages.first
    end

    redirect_to event_cancellation_plans_path

  end

  def update
    
    authorize(@event_cancellation_plan)

    if @event_cancellation_plan.update(event_cancellation_plan_params)
      flash[:success] = "Event Cancellation Plan was successfully updated."
    else
      flash[:error] = @event_cancellation_plan.errors.full_messages.first
    end

    redirect_to event_cancellation_plans_path

  end


  def destroy

    authorize(@event_cancellation_plan)

    if @event_cancellation_plan.destroy
      flash[:success] = "Event Cancellation Plan was successfully destroyed."
    else
      flash[:error] = @event_cancellation_plan.errors.full_messages.first
    end
    
    redirect_to event_cancellation_plans_path

  end

  private

  def locate_collection
    @event_cancellation_plans = EventCancellationPlanPolicy::Scope.new(current_user, EventCancellationPlan).resolve(filtering_params).order('event_cancellation_plans.name ASC').page(params[:page]).per(params[:per_page])
  end

  def set_event_cancellation_plan
    @event_cancellation_plan = EventCancellationPlan.find(params[:id])
  end

  def event_cancellation_plan_params
      params.require(:event_cancellation_plan).permit(:name)
  end

  def filtering_params
    params.slice(:event_cancellation_plan_name)
  end
  
end
