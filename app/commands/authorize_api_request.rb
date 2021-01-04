class AuthorizeApiRequest
  prepend SimpleCommand

  include JwtHelper
  
  def initialize(headers = {})
    @headers = headers
  end
  
  def call
    user
  end
  
  private 
  
  attr_reader :headers
  
  def user
    @user ||= if token.present? then
      token.touch(:last_used_at) if token.last_used_at < 10.minutes.ago
      token.try(:user)
    else
      errors.add(:token, 'Invalid token') && nil
    end
  end

  def token
    @token ||= AuthenticationToken.find_by_body(decoded_auth_token) if decoded_auth_token.present?
  end
  
  def decoded_auth_token
    @decoded_auth_token ||= find_key_in_jwt('authentication_token', http_auth_header)
  end
  
  def http_auth_header
    if headers['Authorization'].present?
      return headers['Authorization'].split(' ').last
    else
      errors.add(:token, 'Missing token')
    end
    nil
  end

end