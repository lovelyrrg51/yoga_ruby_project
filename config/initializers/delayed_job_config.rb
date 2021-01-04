# config/initializers/delayed_job_config.rb
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 2
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 60.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = ENV['DELAYED_JOB_DEFAULT_QUEUE_NAME']
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.raise_signal_exceptions = false #:term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
