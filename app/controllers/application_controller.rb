class ApplicationController < ActionController::Base
  include ApplicationHelper
  include CommonHelper
  include Pundit
  include Concerns::PunditNamespaces
  include Orderable
  include PublicActivity::StoreController

  after_action :prepare_unobtrusive_flash

  protect_from_forgery with: :exception, prepend: true

  before_action :set_request_ip_and_current_user_id, :prepare_exception_notifier
  before_action :store_current_location, unless: :devise_controller?
  around_action :set_global
  before_action :create_cms_site, if: :site_not_exists?

  def current_sadhak_profile
    current_user.try(:sadhak_profile)
  end

  protected

  def set_necessary_methods_on_application_record
    klasses = [ApplicationRecord]
    methods = ["current_user", "signed_in?"]
    methods.each do |m|
      inst_var = send(m)
      klasses.each do |klass|
        klass.send(:define_method, m, proc { inst_var })
      end
    end
    yield
    methods.each do |m|
      klasses.each do |klass|
        klass.send :remove_method, m if klass.send(:instance_methods, false).include?(m.to_sym)
      end
    end
  end

  def set_global
    methods = %w(request current_user)
    Global.class_eval do
      methods.each do |m|
        attr_accessor m
      end
    end
    methods.each do |m|
      Global.instance.send("#{m}=", send(m))
    end
    yield
    methods.each do |m|
      Global.instance.send("#{m}=", nil)
    end
  end

  private

  def prepare_exception_notifier
    exception_data = {base_url: request.base_url}
    exception_data.merge!({current_user: current_user}) if signed_in?
    request.env["exception_notifier.exception_data"] = exception_data
  end

  def set_request_ip_and_current_user_id
    # TODO: refactor, not to use global variable
    $ip = request.ip
    $current_user = current_user
    session ||= {}
    geo_location = session[:geo_location] || {}
  end

  def lat
    cookies[:lat].to_f
  end

  def lng
    cookies[:lng].to_f
  end

  def store_current_location
    return if (request.xhr? || request.format == :json || !request.get?)
    if self.class.const_defined?("NON_STORABLE_ACTIONS") && self.class::NON_STORABLE_ACTIONS.include?(action_name)
      store_location_for(:user, request.base_url)
    else
      store_location_for(:user, request.url)
    end
  end

  def after_sign_out_path_for(resource)
    root_path
  end

  def action_missing(m, *args, &block)
    redirect_to '/*path'
  end

  def pundit_namespace
    self.class.try(:parent_name)
  end

  def create_cms_site
    ::Comfy::Cms::Site.create(label: 'Shivyoug-cms', identifier: 'Shivyoug-cms', hostname: hostname)
  end

  def site_not_exists?
    return false unless params[:controller] == "comfy/admin/cms/base"
    ::Comfy::Cms::Site.count.zero?
  end

  def hostname
    [request.host, request.port].join(':')
  end
end
