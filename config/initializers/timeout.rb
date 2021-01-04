if Rails.env.production?
  Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 30000  # seconds
  Rack::Timeout.unregister_state_change_observer(:logger)
else
  Rails.application.config.middleware.delete Rack::Timeout
end
