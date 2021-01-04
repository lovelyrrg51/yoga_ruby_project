namespace :temp do
  task :one_time_email_to_siddha_virtual_shivir_level_1 do |t|
    
    event_ids = Event.where("event_start_date < ?", Date.today).where(status: [3, 4, 6], event_type_id: 41).pluck(:id)
    
    EventRegistration.where(event_id: event_ids, status: EventRegistration.valid_registration_statuses).order(:id).includes({sadhak_profile: [{address: [:db_city, :db_state, :db_country]}]}, :event_order).group_by(&:event_order).each do |event_order, registrations|

      sadhak_emails = registrations.collect{|r| r.try(:sadhak_profile).try(:email)}
      ApplicationMailer.send_email(recipients: sadhak_emails, subject: "A DIVINE GIFT FOR YOU.", template: "one_time_email_to_siddha_virtual_shivir_level_1").deliver
    end
  end
  # desc "Common task"
  # task :all => [:task1, :task2]
  # Rake::Task["all"].invoke
  # Rake::Task[:task1].invoke 1
  # Rake::Task[:task2].invoke 2
end
