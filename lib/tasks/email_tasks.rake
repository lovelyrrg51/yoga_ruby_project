namespace :email_tasks do
  desc 'Notify Admins about ready events'
  task admins_notify_ready_events: :environment do
    puts 'hello'
    Reports::ReadyEventOrdersReport.call
    puts 'done'
  end

  desc 'Forum members details per forum'
  task :forum_members_report, [:sy_club_ids] => :environment do |t, args|
    SyClub.last.forum_members_report(args[:sy_club_ids])
  end

  # rake email_tasks:pre_approval_event_order_daily_email
  desc 'Send email to pre approval event order on approval'
  task pre_approval_event_order_daily_email: :environment do
    event_orders = EventOrder.where(status: EventOrder.statuses['approve'])
    if event_orders.count > 0
      update_successes = event_orders.map { |m| m.update(status: EventOrder.statuses['approve']) }
      if update_successes.count == event_orders.count
        puts 'Successfully notified.'
      else
        puts 'Something went wrong.'
      end
    end
  end

  # Auto migrtion for forum members to clp product
  desc 'Forum members registration to clp'
  task clp_registrations: :environment do
    Rake::Task['clp_migration:clp_data_migration'].execute
  end

  # rake email_tasks:manual_refund_requests_report
  desc 'Report: manual refund request'
  task manual_refund_requests_report: :environment do
    errors = PaymentRefund.send_daily_manual_refund_report
    Rails.logger.info("Task Status: manual_refund_requests_report: #{Time.now}")
    if errors.empty?
      Rails.logger.info('Successfully completed task.')
    else
      Rails.logger.info("Errors occured, errors: #{errors}") unless errors.empty?
    end
  end

  desc 'Event summary report'
  task event_summary_report: :environment do
    Rails.logger.info("Task event_summary_report started at: #{Time.now}")
    puts "Task event_summary_report started at: #{Time.now}"
    Reports::EventSummaryReports.global_summary
    Rails.logger.info("Task event_summary_report completed at: #{Time.now}")
    puts "Task event_summary_report completed at: #{Time.now}"
  end

  desc 'Nightly script to expire clp membership.'
  task mark_clp_members_expired_and_send_email: :environment do
    Rake::Task['clp_migration:mark_clp_members_expired_and_send_email'].execute
  end

  desc 'India Event summary report'
  task india_event_summary_report: :environment do
    Rails.logger.info("Task india_event_summary_report started at: #{Time.now}")
    puts "Task india_event_summary_report started at: #{Time.now}"
    Reports::EventSummaryReports.india_summary
    Rails.logger.info("Task india_event_summary_report completed at: #{Time.now}")
    puts "Task india_event_summary_report completed at: #{Time.now}"
  end

  desc 'Global-India forum summary report'
  task :forum_summary_report, [:india_or_global] => :environment do |t, args|
    scope = args[:india_or_global].to_s.downcase.strip
    Reports::ForumSummaryReports.try("#{scope}_summary")
    puts "#{scope} forum summary report successfully sent. #{Time.now}"
  end

  desc 'Send event gifts'
  task :send_event_gifts, [:event_type_id] => :environment do |t, args|
    Rails.logger.info("Task send_event_gift started at: #{Time.now}")
    EventGiftLog.send_gifts(args[:event_type_id])
    Rails.logger.info("Task send_event_gift completed at: #{Time.now}")
  end

  desc 'Send Weekly Sadhak Profiles Report'
  task :weekly_sadhak_profiles_details, [:recipients] => :environment do |t, args|
    if Date.today.wday.zero?
      Rails.logger.info("Task weekly_sadhak_profiles_details started at: #{Time.now}")
      SadhakProfile.find(70102).weekly_sadhak_profiles_details({ recipients: args[:recipients] })
      Rails.logger.info("Task weekly_sadhak_profiles_details completed at: #{Time.now}")
    end
  end
end
