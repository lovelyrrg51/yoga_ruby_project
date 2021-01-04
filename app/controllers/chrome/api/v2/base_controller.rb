class Chrome::Api::V2::BaseController < ApplicationController

    protect_from_forgery prepend: true

    before_action :set_current_user

    attr_reader :current_user

    def encode_token(payload = {})
        return JWT.encode(payload, Rails.application.secrets.secret_key_base)
    end

    def decode_token(token)
        begin
            return HashWithIndifferentAccess.new(JWT.decode(token, Rails.application.secrets.secret_key_base)[0])
        rescue Exception => e
            return {}
        end      
    end

    def set_current_user
       @current_user = find_current_user
    end
    
    private

    def find_current_user

        if request.headers["auth-token"].present?

            decoded_auth_token = decode_token(request.headers["auth-token"])

            return unless decoded_auth_token[:username].present? || decoded_auth_token[:syid].present?
            
            user = SadhakProfile.find_by_syid(decoded_auth_token[:syid]).try(:user)

            return unless user.present? || user.username.eql?(decoded_auth_token[:username])

            user

        end

    end

    def get_token(user)
        return encode_token({
            username: user.try(:username),
            syid: user.try(:sadhak_profile).try(:syid)
        })
    end
  
end