module V2
  class ForumsRequestController < BaseController
    before_action :authenticate_user!

    def create
      @forum_request = current_user.create_forum_requests.new(forum_request_params)
      if @forum_request.save

        flash[:success] = "Forum Request created Successfully"
        redirect_to(request.env['HTTP_REFERER'])
      else
        flash[:error] = "Something went wrong"
        redirect_to(request.env['HTTP_REFERER'])
      end
    end

    private
    
    def forum_request_params
      params.require(:create_forum_request).permit(:name, :no_of_people, :about_forum, :description, :motive)
    end
  end
end