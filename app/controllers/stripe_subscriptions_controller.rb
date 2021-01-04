class StripeSubscriptionsController < ApplicationController
  before_action :set_stripe_subscription, only: [:show, :edit, :update, :destroy]

  # GET /stripe_subscriptions
  def index
    @stripe_subscriptions = StripeSubscription.all
  end

  # GET /stripe_subscriptions/1
  def show
  end

  # GET /stripe_subscriptions/new
  def new
    @stripe_subscription = StripeSubscription.new
  end

  # GET /stripe_subscriptions/1/edit
  def edit
  end

  # POST /stripe_subscriptions
  def create
    # @stripe_subscription = StripeSubscription.new(stripe_subscription_params)

    redirect_to EventOrder.find(stripe_subscription_params[:event_order_id]), notice: 'Stripe subscription was successfully created.'

    # if @stripe_subscription.save
    #   redirect_to @stripe_subscription, notice: 'Stripe subscription was successfully created.'
    # else
    #   render :new
    # end
  end

  # PATCH/PUT /stripe_subscriptions/1
  def update
    if @stripe_subscription.update(stripe_subscription_params)
      redirect_to @stripe_subscription, notice: 'Stripe subscription was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /stripe_subscriptions/1
  def destroy
    @stripe_subscription.destroy
    redirect_to stripe_subscriptions_url, notice: 'Stripe subscription was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stripe_subscription
      @stripe_subscription = StripeSubscription.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def stripe_subscription_params
      params.require(:stripe_subscription).permit(:event_order_id, :stripe_token, :amount)
    end
end
