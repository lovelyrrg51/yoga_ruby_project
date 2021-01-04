module Api::V1
  class HomeController < BaseController
    #before_action :authenticate_user!
  #  layout "main_index.html.erb", :only => :index
  
  
    def index
      redis_index_page = index_html
      if params.has_key?('flash')
        if params[:flash].has_key?('intended_path')
          redis_index_page.sub! "intended_destination_string_to_replace", params[:flash][:intended_path]
        end
      end
  
      render text: redis_index_page
    end
  
    private
  
    def index_html
      redis.get "#{deploy_key}:index.html"
    end
  
    # By default serve release, if canary is specified then the latest
    # known release, otherwise the requested version.
    def deploy_key
      params[:version] ||= 'release'
      case params[:version]
      when 'release' then 'release'
      when 'canary'  then  redis.lindex('releases', 0)
      else
        params[:version]
      end
    end
  
    def redis
      if Rails.env.development?
  #      redis = Redis.new()
        Redis.new(:url => 'redis://grouper.redistogo.com:10438', :password => "8b8b5a7f29c55dbdbdf6ff238cf1a815")
      else
        #Redis.new(:url => 'redis://grouper.redistogo.com:10438')
        Redis.new(:url => ENV['REDISTOGO_URL'])
      end
    end
  end
end
