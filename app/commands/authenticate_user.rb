class AuthenticateUser
  prepend SimpleCommand
  
  def initialize(username, password, request, current_user)
    @username = username
    @password = password
    @request = request
    @current_user = current_user
    @resource = User.find_for_database_authentication(username)
  end
  
  def call
    if current_user.present?
      {auth_token: http_auth_header, type: 'Bearer', time_zone_offset: Time.zone_offset(Time.now.zone), server_time: Time.now.gmtime.iso8601}
    elsif find_resource.present?
      @current_user = find_resource
      {auth_token: TokenIssuer.create_token(find_resource, request), type: 'Bearer', time_zone_offset: Time.zone_offset(Time.now.zone), server_time: Time.now.gmtime.iso8601}
    end
  end
  
  private
  
  attr_accessor :username, :password, :request, :current_user, :resource

  def find_resource
    return nil if errors.present?
    begin
      raise "user not found." unless resource.present?
      raise "invalid credentials." unless resource.valid_password?(password)
      return resource
    rescue => e
      errors.add :user_authentication, e.message
    end
    nil
  end

  def http_auth_header
    request.headers['Authorization'].split(' ').last
  end

end
