module JwtHelper
  extend ActiveSupport::Concern

  require 'jwt'

  JWT_SECRET = Rails.application.secrets.jwt_secret
  JWT_ALGORITHM = Rails.application.secrets.jwt_algorithm
  JWT_TOKEN_VALIDITY = Rails.application.secrets.jwt_token_validity

  included do
    def self.encode_jwt(payload = {})
      payload = payload.merge(exp: (Time.now.to_i + JWT_TOKEN_VALIDITY.to_i), iat: Time.now.to_i)
      JWT.encode payload, JWT_SECRET, JWT_ALGORITHM
    end

    def self.decode_jwt(_token)
      JWT.decode _token, JWT_SECRET, true, { algorithm: JWT_ALGORITHM }
    rescue JWT::ExpiredSignature, JWT::InvalidIatError, StandardError
      {}
    end

    def self.find_key_in_jwt(key, jwt_token)
      (decode_jwt(jwt_token).find{ |_h| _h.keys.include?(key) } || {})[key]
    end

  end

  def encode_jwt(payload = {})
    self.class.encode_jwt payload
  end

  def find_key_in_jwt(key, jwt_token)
    self.class.find_key_in_jwt(key, jwt_token)
  end

end

