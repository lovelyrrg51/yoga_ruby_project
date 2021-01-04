# frozen_string_literal: true

class Reports::EventSummaryReports
  class << self

    def global_summary
      details = Event.where(
        'status IN (?) AND event_end_date + 10 >= ?',
        Event.statuses.slice(:ready, :test_registration).values,
        Date.today
      ).where('event_type_id > ?', 0)
        .joins(:address)
        .where.not(addresses: {country_id: 113})
        .includes(
          { address: [:db_country] },
          :event_type,
          :event_seating_category_associations,
          :valid_event_registrations
        ).uniq.group_by(&:graced_by).sort

      addresses = []

      details.each do |_, events|
        (events || []).each do |e|
          addresses.push(e.address) if e.address.present?
        end
      end

      emails = GlobalPreference.get_value_of('event_summary_report_email')
      if emails.present?
        ApplicationMailer.send_email(
          from: 'support@absclp.com',
          recipients: emails.split(','),
          template: 'event_summary_report',
          subject: "Global Event(s) Summary Report - #{Time.now.strftime('%d%m%Y%H%M%S%N')}",
          event_details: details,
          address_details: addresses
        ).deliver
      end
    end

    def india_summary
      details = Event.where(
        'status IN (?) AND event_end_date + 10 >= ? AND entity_type IS ?',
        Event.statuses.slice(:ready, :test_registration).values,
        Date.today, nil
      ).where('event_type_id > ?', 0)
        .joins(:address)
        .where('addresses.country_id = ?', 113)
        .includes(
          { address: [:db_country] },
          :event_type,
          :event_seating_category_associations,
          :valid_event_registrations
        ).uniq.group_by(&:graced_by).sort

      addresses = []

      details.each do |_, events|
        (events || []).each do |e|
          addresses.push(e.address) if e.address.present?
        end
      end

      emails = GlobalPreference.get_value_of('india_event_summary_report')
      if emails.present?
        ApplicationMailer.send_email(
          from: 'registration@shivyogindia.com',
          recipients: emails.split(','),
          template: 'india_event_report',
          subject: "India Event(s) Summary Report - #{Time.now.strftime('%d%m%Y%H%M%S%N')}",
          event_details: details,
          address_details: addresses
        ).deliver
      end
    end

  end
end
