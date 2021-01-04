class TokenIssuer
  include JwtHelper

  MAXIMUM_TOKENS_PER_USER = Rails.application.secrets.maximum_tokens_per_user || 1

  def self.build
    new(MAXIMUM_TOKENS_PER_USER)
  end

  def self.create_token(resource, request)
    build.create_token(resource, request)
  end

  def self.expire_token(resource, request)
    build.expire_token(resource, request)
  end

  def initialize(maximum_tokens_per_user)
    self.maximum_tokens_per_user = maximum_tokens_per_user
  end

  def create_token(resource, request)

    # Get unique auth token
    auth_token = loop do
      _auth_token = Devise.friendly_token(50)
      break _auth_token unless AuthenticationToken.exists?(body: _auth_token)
    end

    # Create a new authentication token entry
    token = resource.authentication_tokens.create!(
        last_used_at: DateTime.current,
        ip_address:   request.remote_ip,
        user_agent:   request.user_agent,
        body: auth_token)

    purge_old_tokens(resource)

    # Update resource details
    resource.update(sign_in_count: resource.sign_in_count.to_i + 1, current_sign_in_at: token.last_used_at, last_sign_in_at: resource.current_sign_in_at, current_sign_in_ip: token.ip_address, last_sign_in_ip: resource.current_sign_in_ip)

    encode_jwt(authentication_token: token.body)
  end

  def expire_token(resource, request)
    find_token(resource, token_from_request(request)).try(:destroy)
  end

  def find_token(resource, _token)
    resource.authentication_tokens.detect do |token|
      token.body == _token
    end
  end

  def purge_old_tokens(resource)
    resource.authentication_tokens
        .order(last_used_at: :desc)
        .offset(maximum_tokens_per_user)
        .destroy_all
  end

  private

  attr_accessor :maximum_tokens_per_user

  def token_from_request(request)
    find_key_in_jwt('authentication_token', request.headers['Authorization'].to_s.split(' ').last || request.headers['X-User-Token'])
  end

end
