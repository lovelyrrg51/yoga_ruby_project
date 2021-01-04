# frozen_string_literal: true

class Reports::ReadyEventOrdersReport

  def self.call
    event_registration = EventRegistration.last

    # Iterate over ready events only
    Event.where(status: Event.statuses.slice(:test_registration, :ready).values).find_each do |event|
      begin
        next if event.event_end_date + 1 < Date.today
        # Hold seating category seats details
        seating_category_details = []

        # Calculate seating category data
        event.event_seating_category_associations.each do |sc|
          seating_category_details.push({
            total_seats: sc.try(:seating_capacity),
            seats_occupied: event.event_registrations.where(event_seating_category_association_id: sc.id, status: EventOrderLineItem.valid_line_item_statuses).count,
            extra_seats: event.event_registrations.where(event_seating_category_association_id: sc.id, is_extra_seat: true, status: EventOrderLineItem.valid_line_item_statuses).count,
            category_name: sc.try(:seating_category).try(:category_name)
          })
        end

        # Recieptients
        recipients = event.registrations_recipients.try(:send, :split, ",")

        # Generate data for excel
        blob = event_registration.do_generate_event_registration_file(event, false, false, "xls")

        if recipients.present? and recipients.extract_valid_emails.count > 0

          # Extract valid emails
          recipients = recipients.extract_valid_emails

          # Reciepitents changed according to environment
          recipients = ['prince@metadesignsolutions.in'] if Rails.env == "development"

          file_name = "#{event.try(:event_name_with_location)}_registrations_#{event.id}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"
          attachments = Hash[file_name, blob]

          from = GetSenderEmail.call(event)
          ApplicationMailer.send_email(
            from: from,
            recipients: recipients,
            template: 'send_daily_email',
            subject: "#{event.try(:event_name_with_location)} registrations list and seating categories details - #{Time.now.strftime('%d%m%Y%H%M%S%N')}",
            attachments: attachments,
            seating_category_details: seating_category_details,
            event: event
          ).deliver
        end
      rescue => e
        Rollbar.error(e)
      end
    end
  end

end
