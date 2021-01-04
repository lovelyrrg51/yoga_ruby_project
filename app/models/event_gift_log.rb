class EventGiftLog < ApplicationRecord
  belongs_to :event
  has_many :attachments, as: :attachable

  validates :event_id, presence: true, uniqueness: true

  enum status: [ :initiated, :processing, :done, :failed ]

  class << self

    # Send gifts to Siddha Healing Virtual Shivir Level 1
    # @return nothing
    def send_gifts(event_type_id = nil)
      event_type_id ||= 41

      already_sent_event_ids = self.pluck(:event_id)

      Event.where('event_end_date < ? AND status IN (?) AND event_type_id = ?', Date.today, Event.statuses.slice(:test_registration, :ready, :closed).values, event_type_id).where.not(id: already_sent_event_ids).order(:id).includes({valid_event_registrations: [{sadhak_profile: [{address: [:db_city, :db_state, :db_country]}]}, :event_order]}).each do |event|
        begin
          event_gift_log = self.new(event_id: event.id, status: self.statuses['initiated'])
          raise Exception, event_gift_log.errors.full_messages.first unless event_gift_log.save

          errors = []
          processed = []

          event_gift_log.update_columns(status: self.statuses['processing'])

          from = GetSenderEmail.call(event)

          event.valid_event_registrations.each do |registration|
            sadhak_profile = registration.try(:sadhak_profile)
            sadhak_email = sadhak_profile.try(:email).to_s

            # Don't send email and sms if sadhak is banned from event
            next if !sadhak_profile.present? || sadhak_profile.banned?

            message = nil

            if sadhak_email.extract_valid_emails.present?
              begin
                ApplicationMailer.send_email(from: from, recipients: sadhak_email, subject: 'A DIVINE GIFT FOR YOU.', template: 'one_time_email_to_siddha_virtual_shivir_level_1', event: event, sadhak_profile: sadhak_profile).deliver
              rescue Aws::SES::Errors::ServiceError => e
                message = e.message
              rescue Exception => e
                message = e.message
              end

              if message.present?
                errors.push([registration.sadhak_profile_id, registration.event_id, registration.id, message])
              else
                processed.push([registration.sadhak_profile_id, registration.event_id, registration.id, "Sent on email: #{sadhak_email}"])
              end
            elsif false #sadhak_profile.try(:mobile).present?
              result =  sadhak_profile.send_sms_to_sadhak("NMS #{sadhak_profile.try(:full_name)}\nThank you for attending the #{event.try(:event_name)}. Here is a Gift from Baba ji. Please do not share it with anyone.\nTo Download: https://goo.gl/pc61l5")
              if result
                processed.push([registration.sadhak_profile_id, registration.event_id, registration.id, "Sent on mobile: #{sadhak_profile.try(:mobile)}"])
              else
                errors.push([registration.sadhak_profile_id, registration.event_id, registration.id, 'Sadhak address is missing.'])
              end
            else
              errors.push([registration.sadhak_profile_id, registration.event_id, registration.id, "No mobile or email found. Mobile: #{sadhak_profile.try(:mobile)} - Email: #{sadhak_email}"])
            end
          end

          begin
            # Generate success sadhak profiles
            event.generate_excel_and_upload(rows: processed, header: %w(SADHAK_PROFILE_ID EVENT_ID REGISTRATION_ID MESSAGE), file_name: "event-#{event.id}-event-gift-log-id-#{event_gift_log.id}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/event_gift_logs") if processed.size > 0
          rescue => e
            Rails.logger.info("Error occured while generating success file for event: #{event.id}, message: #{e.message}.")
            Rollbar.error(e)
          end

          begin
            # Generate failed sadhak profiles
            event.generate_excel_and_upload(rows: errors, header: %w(SADHAK_PROFILE_ID EVENT_ID REGISTRATION_ID ERROR_MESSAGE), file_name: "event-#{event.id}-event-gift-log-id-#{event_gift_log.id}-failed.xls", prefix: "#{ENV['ENVIRONMENT']}/event_gift_logs") if errors.size > 0
          rescue => e
            Rails.logger.info("Error occured while generating errors file for event: #{event.id}, message: #{e.message}.")
            Rollbar.error(e)
          end

          event_gift_log.update_columns(status: self.statuses['done'])
        rescue => e
          Rollbar.error(e)
        end
      end
    end

  end
end
