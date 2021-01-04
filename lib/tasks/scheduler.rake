  # http://aakashsharmaror.blogspot.in/2013/01/actionmailer-rake-task-scheduler.html
  desc 'This task is called by the Heroku scheduler add-on'
  task :admins_ready_events_registrations => :environment do
    puts 'Sending'
    Reports::ReadyEventOrdersReport.call
    puts 'done.'
  end

  desc 'Forum members details per forum'
  task :forum_members_report, [:sy_club_ids] => :environment do |t, args|
    Rake::Task['email_tasks:forum_members_report'].invoke(args[:sy_club_ids])
  end

  # Auto migrtion for forum members to clp product
  desc 'Forum members registration to clp'
  task clp_registrations: :environment do
    Rake::Task['email_tasks:clp_registrations'].execute
  end

  # Task to send manual refunds report
  desc 'Report: manual refund request'
  task manual_refund_requests_report: :environment do
    Rake::Task['email_tasks:manual_refund_requests_report'].execute
  end

  #Generate event summary report
  desc 'Event summary report'
  task event_summary: :environment do
    Rake::Task['email_tasks:event_summary_report'].execute
  end

  #Auto migrtion for forum members to clp product
  desc 'Forum organizers registration to clp'
  task clp_registrations: :environment do
    Rake::Task['clp_migration:organizers_data_migration'].execute
  end

  desc 'Nightly script to expire clp membership.'
  task mark_clp_members_expired_and_send_email: :environment do
    Rake::Task['clp_migration:mark_clp_members_expired_and_send_email'].execute
  end

  # Generate India events summary reports
  desc 'India events summary report'
  task india_event_summary: :environment do
    Rake::Task['email_tasks:india_event_summary_report'].execute
  end

  desc 'Global-India forum summary report'
  task :forum_summary_report, [:india_or_global] => :environment do |t, args|
    Rake::Task['email_tasks:forum_summary_report'].invoke(args[:india_or_global])
  end

  # Send event gifts
  desc 'Send event gifts to Siddha Healing Virtual Shivir Level 1 type shivirs'
  task :send_event_gifts, [:event_type_id] => :environment do |t, args|
    Rake::Task['email_tasks:send_event_gifts'].invoke(args[:event_type_id])
  end

  desc "Reminder email and SMS to sadhaks who's profile photo and photo id is rejected."
  task reminder_email_sms_to_profile_photo_and_photo_id_rejected: :environment do
    Rake::Task['admin:reminder_email_sms_to_profile_photo_and_photo_id_rejected'].execute
  end

  desc 'Send episode attendance as email to all board members if edited. Daily at 11:45 UTC'
  task :send_episode_attendance_if_edited, [:recipients] => :environment do |t, args|
    Rake::Task['forum:send_episode_attendance_if_edited'].invoke(args[:recipients])
  end

  desc 'Send episode attendance as email to individual sadhak. Monthly on 1st at 11:50 UTC'
  task :send_episode_attendance_to_individual_sadhak, [:recipients] => :environment do |t, args|
    Rake::Task['forum:send_episode_attendance_to_individual_sadhak'].invoke(args[:recipients])
  end

  desc 'Send graphical episode attendance as email to Ashram. Every Monday at 11:40 UTC'
  task :send_graphical_attendance_report_to_ashram, [:recipients] => :environment do |t, args|
    Rake::Task['forum:send_graphical_attendance_report_to_ashram'].invoke(args[:recipients])
  end

  desc 'Send bar chart report of each sadhak as email to all board members. In every 3 months at 11:45 UTC'
  task :send_graphical_report_of_each_sadhak_attended_to_board_members, [:recipients] => :environment do |t, args|
    Rake::Task['forum:send_graphical_report_of_each_sadhak_attended_to_board_members'].invoke(args[:recipients])
  end

  desc 'Send bar chart reporSend consolidated forum attendance report. Daily at 00:00 UTC'
  task :consolidated_forum_attendance_report, [:region, :recipients] => :environment do |t, args|
    Rake::Task['forum:consolidated_forum_attendance_report'].invoke(args[:region], args[:recipients])
  end

  desc 'Migration for Forum Board Members'
  task :forum_boad_member_migration, [:recipients] => :environment do |t, args|
    Rake::Task['forum_data_migration:forum_boad_member_migration'].invoke(args[:recipients])
  end

  #30 18 * * * /bin/bash -l -c 'cd /home/ubuntu/apps/shivyog-rails-production/current && RAILS_ENV=production bundle exec rake reminder_email_sms_to_profile_photo_and_photo_id_rejected >/dev/null 2>&1'
