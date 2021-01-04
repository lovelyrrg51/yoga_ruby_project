class DiscountPlansController < ApplicationController

  before_action :set_discount_plan, only:[:edit, :update, :destroy]
  before_action :set_discounted_events, only: [:edit, :index]
  before_action :authenticate_user!

  def index

    @discount_plan = DiscountPlan.new

    authorize(@discount_plan)

    @discount_plans = policy_scope(DiscountPlan)

  end

  def edit

    authorize(@discount_plan)

  end

  def create

    @discount_plan = DiscountPlan.new(discount_plan_params)

    authorize(@discount_plan)

    if @discount_plan.save
      flash[:success] = "Sy Club validity Window was successfully created."
    else
      flash[:error] = @discount_plan.errors.full_messages.first
    end

    redirect_to discount_plans_path

  end

  def update

    authorize(@discount_plan)

    if @discount_plan.update(discount_plan_params)
      flash[:success] = "Sy Club validity Window was successfully updated."
    else
      flash[:error] = @discount_plan.errors.full_messages.first
    end

    redirect_to discount_plans_path

  end


  def destroy

    authorize(@discount_plan)

    if @discount_plan.destroy
      flash[:success] = "Sy Club validity Window was successfully destroyed."
    else
      flash[:error] = @discount_plan.errors.full_messages.first
    end
    
    redirect_to discount_plans_path

  end


  private

  def set_discount_plan
    @discount_plan = DiscountPlan.find(params[:id])
  end

  def discount_plan_params
      params.require(:discount_plan).permit(:name, :discount_type, :discount_amount, :event_id, event_ids: [])
  end

  def set_discounted_events
    @discounted_events = Event.where('end_date_ignored = ? OR event_end_date < ? AND event_end_date IS NOT ?', true, Time.current, nil) 
  end
end
