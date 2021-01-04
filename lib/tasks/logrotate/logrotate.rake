namespace :logrotate do

  include CommonHelper

  desc 'This task will run on generated zipped log files after logrotate on each environment.'
  task :upload_logs_s3, [] => :environment do |t, args|

    prefix = Time.now.strftime('%d-%m-%Y %I:%M:%S:%6N %p %:z')

    Dir.glob(Rails.root.join('log', "*.log-#{Date.today.strftime('%Y%m%d')}.gz")).each do |file_path|

      begin

        Rails.logger.info("Rake::Task::upload_logs_s3 - Processing file: #{file_path} - #{Time.now.to_s}")

        env = ENV['RAILS_ENV'] || 'production'

        next unless File.exist?(file_path)

        file_name = File.basename(file_path)

        file = File.open(file_path, 'r')

        s3_key = "#{env}/#{prefix}/#{file_name}"

        bucket = Aws::S3::Bucket.new(ENV['SHIVYOG_APP_LOGS_BUCKET'])

        s3_file = bucket.put_object(acl: 'private', body: file, content_type: MIME::Types.type_for(file_path).first.content_type, key: s3_key)

        file.close

        File.delete(file) if s3_file.exists?

      rescue Exception => e
        Rails.logger.error("Rake::Task - upload_logs_s3 - Error- #{e.message}")
      end

    end

  end

end
