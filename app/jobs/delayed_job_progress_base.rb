class DelayedJobProgressBase < Struct.new(:options)

  include CommonHelper

  attr_accessor :delayed_job_progress, :s3, :job

  def perform

    raise "Perform method is not implemented in #{self.class}."

  end

  def before(job)

    options = (self.options || {}).dup

    @job = job

    @s3 = Aws::S3::Client.new

    @_link_expires_time = options[:expires_in] || 20.minutes

    @progress_max = options[:progress_max] || 100

    @_max_run_time = options[:max_run_time] || Delayed::Worker.max_run_time

    @_max_attempts = options[:max_attempts] || Delayed::Worker.max_attempts

    @_queue_name = options[:queue_name] || Delayed::Worker.default_queue_name

    @_destroy_failed_jobs = options[:destroy_failed_jobs] || Delayed::Worker.destroy_failed_jobs

    @delayed_job_progress = options[:delayed_job_progress]

    @batch_size = options[:batch_size] || 10000

    raise 'Delayed Job Progress cannot be blank.' unless @delayed_job_progress.present?

    @delayed_job_progress.update_columns(progress_max: @progress_max, progress_current: 0.0, progress_stage: 'Queued', last_error: nil, result: nil, status: DelayedJobProgress.statuses[:initiated])

    update_progress_status(DelayedJobProgress.statuses[:processing])

  end

  def update_progress(step: 1)

    delayed_job_progress.update_column(:progress_current, delayed_job_progress.progress_current + step)

  end

  def update_stage(stage)

    delayed_job_progress.update_column(:progress_stage, stage)

  end

  def update_stage_progress(stage, step: 1)

    update_stage(stage)

    update_progress(step: step)

  end

  def update_progress_max(progress_max)

    delayed_job_progress.update_column(:progress_max, progress_max)

  end

  def update_last_error(last_error)

    delayed_job_progress.update_columns(last_error: last_error)

  end

  def update_progress_result(result = {})

    delayed_job_progress.update_columns(result: result.to_json)

  end

  def destroy_delayed_job_progress

    delayed_job_progress.destroy

  end

  def update_progress_status(status)

    delayed_job_progress.update_columns(status: status)

  end

  def seconds_to_hms(t = 0)

    Time.at(t.to_i).utc.strftime("%H Hour(s) %M Minute(s) %S Second(s)")

  end

  def success(job)

    update_stage("Finished...!!")

    update_progress_max(@progress_max)

    update_progress_status(DelayedJobProgress.statuses[:completed])

    destroy_delayed_job_progress

  end

  def failure(job)

    update_stage("Failed with error: #{delayed_job_progress.last_error}")

    update_progress_status(DelayedJobProgress.statuses[:failed])

    destroy_delayed_job_progress

  end

  # def after(job)
  # end

  def error(job, exception)

    update_stage(exception.message)

    update_last_error(exception.message)

    update_progress_status(DelayedJobProgress.statuses[:error])

    if (job.attempts + 1) < max_attempts

      update_stage("Failed, Retrying(#{job.attempts + 1}). Waiting for Enqueue...!!")

    end

  end

  def queue_name

    @_queue_name

  end

  def max_attempts

    @_max_attempts

  end

  def add_attempts(attempts = 0)

    @_max_attempts = @_max_attempts + attempts.to_i

  end


  def max_run_time

    @_max_run_time

  end

  def add_run_time(run_time = 0)

    @_max_run_time = @_max_run_time + run_time.to_i

  end

  def destroy_failed_jobs?

    @_destroy_failed_jobs

  end

  # def reschedule_at(current_time, attempts)

  #   current_time

  # end

  def link_expires_in

    @_link_expires_time

  end

  def link_for(opts = {})

    opts[:bucket_name] ||= ENV['ATTACHMENT_BUCKET']
    opts[:expires] ||= link_expires_in
    opts[:is_secure] ||= true
    opts[:use_ssl] ||= true
    opts[:method] = (options[:method].is_a?(String) ? options[:method].try(:to_sym) : options[:method]) || :read
    acl = options[:is_secure] == false ? 'public-read' : 'private'

    raise 'File not found' unless opts[:file].present?

    bucket = s3.buckets[opts[:bucket_name]]
    raise 'Bucket not found error.' unless bucket.exists?

    s3_file_path = "#{ENV['ENVIRONMENT']}/jobs/#{self.class.to_s.underscore}/#{Time.now.to_i}#{Random.new_seed.to_s}#{File.extname(opts[:file])}"

    # Upload file to s3
    s3_file = bucket.objects[s3_file_path].write(file: (opts[:file].kind_of?(File) || opts[:file].kind_of?(Tempfile)) ? opts[:file].path : opts[:file], acl: acl, content_type: MIME::Types.type_for(File.basename(opts[:file])).first.content_type)
    raise 'Something went wrong while uploading file. Please try again.' unless s3_file.exists?

    opts[:file].close(true) if File.exists?(opts[:file]) && (opts[:file].kind_of?(File) || opts[:file].kind_of?(Tempfile))

    File.delete(opts[:file].try(:path) || opts[:file]) if File.exists?(opts[:file])

    s3_file.url_for(opts[:method], secure: opts[:is_secure], use_ssl: opts[:use_ssl], expires: opts[:expires].try(:to_i)).to_s

  end

end
