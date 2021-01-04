module V2
  class HomeController < BaseController

    def index
      @upcoming_events ||= Event.upcoming.limit(3).decorate
      @q = SyClub.ransack()
      @blogs = Comfy::Blog::Post.includes(:fragments).limit(4)
    end

    def create_email_subscription
      if EmailSubscription.exists?(email: params[:email_subscription][:email])
        @message = "You already subscribe!"
      else
        email_subscription = EmailSubscription.create(email: params[:email_subscription][:email])
        if EmailSubscription.exists?(email_subscription.id)
          @message = "You have been subscribed successfully!"
        else
          @error = email_subscription.errors.full_messages.first
        end
      end
    end
  end
end
