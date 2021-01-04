defined?(AnyLogin) && AnyLogin.setup do |config|
  # # provider (:devise, :authlogic, sorcery, clearance). Provider can be identified automatically based on your Gemfile
  # config.provider = nil

  # # enabled or not
  # config.enabled = Rails.env.development? || Rails.env.staging? || ENV['ENVIRONMENT'] == 'testing'
  config.enabled = false

  # # Account, User, Person, etc
  # config.klass_name = 'User'

  #  # .all, .active, .admins, .groped_collection, etc ... need to return an array (or hash with arrays) of users
  config.collection_method = :groped_collection_by_role

  # # to format user name in dropdown list
  config.name_method = proc { |e| [e.sadhak_profile.try(:syid), e.id] }

  # # after logging in redirect user to path
  # config.redirect_path_after_login = :root_path

  # # login on select change event OR click on button, or BOTH
  # config.login_on = :both

  # # position of any_login box top_left, top_right, bottom_left, bottom_right
  config.position = :bottom_right

  # # label on Login button
  # config.login_button_label = 'Login'

  # # prompt message in select
  # config.select_prompt = "Select #{AnyLogin.klass_name}"

  # # show any_login box by default
  # config.auto_show = false

  # # limit, integer or :none
  # config.limit = 10

  # # Enable http basic authentication
  # config.http_basic_authentication_enabled = false

  # # Enable http basic authentication
  # config.http_basic_authentication_user_name = 'any_login'

  # # Enable http basic authentication
  # config.http_basic_authentication_password = 'password'

  # # Use controller proc condition
  # config.verify_access_proc = proc { |controller| true }
end
