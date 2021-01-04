module Api::V1
  class CsrfController < BaseController
    before_action :authenticate_user!, except: [:index]
    def index
      render json: { request_forgery_protection_token => form_authenticity_token }.to_json
    end
  end
end
