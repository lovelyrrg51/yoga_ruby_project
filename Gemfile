source 'https://rubygems.org'
ruby "2.5.5"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.2.2'
gem 'pg'
gem 'puma'
gem 'sassc-rails'
gem 'uglifier'
gem 'turbolinks', '~> 5'
gem 'redis', '~> 3.0'
gem 'active_model_serializers', '~> 0.10.0'
gem 'paper_trail', '~> 9.0'
gem 'activerecord-diff'
gem 'devise'
gem 'pundit' # Note this gem is overridden and code can be found in namespaced_pundit
gem 'spreadsheet'
gem 'to_xls'
gem 'roo'
gem 'auto_strip_attributes'
gem 'kaminari'
gem 'aws-sdk-s3'
gem 'aasm'
gem 'msg91ruby'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'razorpay'
gem 'braintree', :git => 'https://github.com/braintree/braintree_ruby'
gem 'pdfkit'
gem 'wkhtmltopdf-binary'
gem 'to_words'
gem 'geocoder'
gem 'delayed_job_active_record'
gem "breadcrumbs_on_rails"
gem 'money'
gem 'offsite_payments'
gem 'paranoia'
gem 'jwt'
gem 'grim'
gem 'gruff'
gem 'geokit-rails'
gem 'rack-timeout'
gem 'figaro'
gem 'amoeba'
gem 'google-api-client'
gem 'rmagick'

gem 'fusioncharts-rails'
gem "cocoon"
# Gem to upload files
gem 'remotipart'
gem 'carrierwave'
gem 'fog-aws'
gem 'friendly_id'
gem 'any_login'
gem 'wicked'
gem 'simple_command'
gem 'rack-attack'
# Use Exception Handler for Implementation of custom error page
gem 'exception_handler'
gem 'bootsnap', require: false

# Gem for editor
gem 'ckeditor'
gem 'mini_magick'
gem "comfortable_mexican_sofa", "~> 2.0.0"

# Gems needs to be integrated
# gem 'jwt_keeper'
# gem 'has_scope'
# gem 'validates'
# gem 'peek'

gem 'public_activity'
gem 'rack-cors', require: 'rack/cors'
gem 'draper'
gem "comfy_blog", "~> 2.0.0"
gem 'social-share-button'
gem 'prismic.io', require: 'prismic'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'pry-rails'
  # gem 'letter_opener'
  # gem 'brakeman', require: false
  # gem 'meta_request'
  # gem 'bullet'
  gem 'rspec-rails', '~> 3.8'
  gem 'rspec-its'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '4.0.0.rc1'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'database_cleaner'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'guard'
  gem 'guard-livereload'

  gem 'rails-erd', require: false

  # For security vulnerabilities
  gem 'brakeman', require: false

  gem 'foreman', require: false
  gem 'letter_opener'
  gem 'rubocop', require: false

  # Profiling
  gem 'rack-mini-profiler' # For database profiling
  gem 'memory_profiler' # For memory profiling
  # For call-stack profiling flamegraphs
  gem 'flamegraph'
  gem 'stackprof'
  gem 'derailed_benchmarks'
end

# UI Dependencies
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'font-awesome-rails'
gem 'jquery-validation-rails'
gem 'underscore-rails'
gem 'select2-rails' # Dont use this gem as bower dependency because it is making root path to load exactly three times.
gem 'browser-timezone-rails'

source 'http://insecure.rails-assets.org' do
  gem 'rails-assets-jquery-ui'
  gem 'rails-assets-ez-plus'
  gem 'rails-assets-toastr'
  gem 'rails-assets-webcamjs'
  gem 'rails-assets-datatables.net-bs'
  gem 'rails-assets-fusioncharts'
  gem 'rails-assets-perfect-scrollbar'
  gem 'rails-assets-js-cookie'
  gem 'rails-assets-malihu-custom-scrollbar-plugin'
  gem 'rails-assets-moment'
  gem 'rails-assets-bootstrap-datetimepicker-3'
  gem 'rails-assets-jquery-mousewheel'
  gem 'rails-assets-bootstrap-star-rating'
  gem 'rails-assets-arboshiki--lobibox'
end
gem 'owlcarousel-rails'

gem 'rollbar'
gem 'validates_timeliness', '~> 5.0.0.alpha3'

gem 'ransack'
gem 'webpacker', '~> 4.0.2'
gem 'jbuilder', '~> 2.7'
gem 'omniauth-google-oauth2'
gem 'phonelib'
gem 'config'
gem 'slim-rails'

# v2 assets
# TODO: use Bootstrap gem after removing v1
# gem 'bootstrap', '~> 4.3.1'
gem 'md_bootstrap', path: 'engines/md_bootstrap'
gem 'unobtrusive_flash', '>=3'
