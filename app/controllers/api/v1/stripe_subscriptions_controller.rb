module Api::V1
  class StripeSubscriptionsController < BaseController
    before_action :set_stripe_subscription, only: [:show, :edit, :update, :destroy]
    before_action :authenticate_user!
    respond_to :json

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
      @subscription = StripeSubscription.new(stripe_subscription_params)
      if @subscription.save
        render json: @subscription
      else
        render json: @subscription.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /stripe_subscriptions/1
    def update
      if @stripe_subscription.update(stripe_subscription_params)
        render json: @stripe_subscription
      else
        render json: @stripe_subscription.errors, status: :unprocessable_entity
      end
    end

    # DELETE /stripe_subscriptions/1
    def destroy
      ss = @stripe_subscription.destroy
      render json: ss
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_stripe_subscription
        @stripe_subscription = StripeSubscription.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def stripe_subscription_params
        params.require(:stripe_subscription).permit!#(:description, :plan, :card)
      end
  end
end
