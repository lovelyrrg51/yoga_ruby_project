# frozen_string_literal: true

module V2
  class AvatarsController < BaseController
    before_action :authenticate_user!

    def create
      if current_sadhak_profile.update(avatar: params[:avatar])
        render json: { success: true, avatar: current_sadhak_profile.avatar_url(:thumb) }
      else
        head :unprocessable_entity
      end
    end

  end
end
