require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
# require 'rails/test_unit/railtie'
require 'sprockets/railtie'
require "active_storage/engine"


# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ShivyogRails
  class Application < Rails::Application
    # Ensuring that ActiveStorage routes are loaded before Comfy's globbing
    # route. Without this file serving routes are inaccessible.
    config.railties_order = [ActiveStorage::Engine, :main_app, :all]
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 5.0

    config.autoload_paths << Rails.root.join('app/models/paper_trail')

    config.active_job.queue_adapter = :delayed_job

    config.action_controller.per_form_csrf_tokens = true

    config.generators do |g|
      g.stylesheets false
      g.test_framework  false
    end

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: [:get, :post, :options]
      end
    end

    config.middleware.use Rack::Attack

    config.exceptions_app = ->(env) { ExceptionHandler::ExceptionsController.action(:show).call(env) }
    config.exception_handler = { dev: true,
      layouts: {
        400 => "application",
        401 => "application",
        402 => "application",
        403 => "application",
        404 => "application",
        500 => "exception",
        501 => "exception",
        502 => "exception",
        503 => "exception",
        504 => "exception",
        505 => "exception"
      }
     }

    config.action_dispatch.rescue_responses["Pundit::NotAuthorizedError"] = :forbidden
    config.action_dispatch.rescue_responses["ActionController::UnknownFormat"] = :bad_request
    # config.active_record.belongs_to_required_by_default = false # able to use this config for debug in development mode
  end
end
