require "#{Rails.root}/app/models/concerns/common_helper"

namespace :admin do
  include CommonHelper

  desc 'Generate sadhak profile excel with filter event type, from date, to date'
  task :sadhak_list_filter_event_type_from_date_to_date, [:event_type, :recipients] => :environment do |t, args|
    begin
      # Find event type
      event_type = EventType.find_by_name("#{args[:event_type]}") || EventType.find_by_id("#{args[:event_type]}")

      event_type_id = event_type.try(:id)

      raise 'Please input a valid event type.' unless event_type_id.present?

      recipients = args[:recipients].to_s.split(',')

      recipients = recipients.extract_valid_emails

      raise 'Please input valid recipients.' if recipients.size == 0

      sadhak_profile_ids = EventRegistration.joins(:event).where(event_registrations: {status: EventRegistration.valid_registration_statuses}, events: {event_type_id: event_type_id}).pluck(:sadhak_profile_id)

      raise 'Sadhak Profiles not found with selected creterion' if sadhak_profile_ids.size == 0

      sadhak_profiles = SadhakProfile.where(id: sadhak_profile_ids).includes({ address: [:db_city, :db_state, :db_country] }).order(:id)

      # Add extra data in generate_sadhak_excel
      opts = [{header_name: 'NAME_OF_GURU', proc: Proc.new{|p| nog = p.try(:name_of_guru); nog.present? ? nog : (p.try(:other_spiritual_associations) || []).sort.collect{|o| o.name_of_guru}.join(',')}}, {header_name: 'SPIRITUAL_ORGANIZATION', proc: Proc.new{|p| org = p.try(:spiritual_org_name); org.present? ? org : (p.try(:other_spiritual_associations) || []).sort.collect{|o| o.organization_name}.join(',')}}]

      # Generate profiles data.
      file = GenerateExcel.generate(GenerateSadhakProfilesExcel.call(sadhak_profiles, nil, opts))

      ApplicationMailer.send_email(recipients: recipients, subject: "#{event_type.name} Attended Sadhak(s) List- #{Time.now.strftime('%d%m%Y%H%M%S%N')}.", attachments: Hash["#{event_type.name}_attended_sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", file]).deliver

      puts "Please check your mail box. Email sent to: #{recipients.join(',')}"

    rescue Exception => e
      Rails.logger.info('Exception in rake task: admin:sadhak_list_filter_event_type_from_date_to_date')
      Rails.logger.info(e.message)
    end
  end

  desc 'Make membership to Aug 31, 2016'
  task :make_membership_to_aug_31, [] => :environment do |t, args|
    header = %w(EVENT_REGISTRATION_ID MEMBER_ID FORUM_ID SADHAK_PROFILE_ID OLD_EXPIRY_DAYS NEW_EXPIRES_AT REG_CREATED_AT)

    success = []

    india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')
    global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')

    new_date = Date.new(2016,9,1)

    EventRegistration.joins(:sy_club_member).where(event_registrations: {status: EventRegistration.valid_registration_statuses, event_id: (india_event_ids + global_event_ids)}).where.not(sy_club_members: {event_registration_id: [nil]}).includes({sadhak_profile: [:user]}, {sy_club_member: [:sy_club]}).uniq.each_with_index do |registration, index|
      sadhak_profile = registration.sadhak_profile
      sy_club_member = registration.sy_club_member
      sy_club = sy_club_member.try(:sy_club)
      next if registration.expires_at.to_i >= (new_date - registration.created_at.to_date).to_i
      if sadhak_profile.present? and sy_club_member.present? and sy_club.present?
        old_expires_at = registration.expires_at.to_i
        new_expiry_at = (new_date - registration.created_at.to_date).to_i
        registration.update_columns(expires_at: new_expiry_at) if new_expiry_at > old_expires_at
        success.push([registration.id, sy_club_member.id, sy_club.id, sadhak_profile.id, old_expires_at, registration.expires_at.to_i, registration.created_at.to_date])
      end
      puts "Processed Record: #{index + 1} - #{registration.id}"
    end

    begin
      Rails.logger.info('Uploading file to S3....')
      EventRegistration.generate_excel_and_upload(rows: success, header: header, file_name: "extended-membership-to-31-aug-2016-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/admin/make_membership_to_aug_31") if success.size > 0
      Rails.logger.info('Upload Success.')
    rescue Exception => e
      Rails.logger.error("Some error occured while uploading file make_membership_to_aug_31: #{e.message}")
      Rollbar.error(e)
    end

    begin
      Rails.logger.info('Sending Email....')
      ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Extended membership validity to Aug 31, 2016 ts: #{Time.now.to_i}", attachments: {"extended-membership-to-31-aug-2016-#{DateTime.now.strftime('%F %T')}-success.xls" => GenerateExcel.generate(rows: success, header: header)}).deliver
      Rails.logger.info('Please check your mailbox.')
    rescue Exception => e
      Rails.logger.error("Some error occured while sending email: #{e.message}")
    end
  end

  desc 'Export renewed sadhak list on india or global forums'
  task :export_renewed_sadhak_list, [:india_or_global] => :environment do |t, args|
    data = []
    header = %w(SYID NAME MOBILE EMAIL FORUM_NAME#ID RENEWED_ON EXPIRATION_DATE CURRENT_REG_ID PREVIOUS_REG_ID)
    if args[:india_or_global] == 'india'
      event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')
    elsif args[:india_or_global] == 'global'
      event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')
    else
      raise 'Please input some argument in task.'
    end
    EventRegistration.where(event_id: event_ids, status: EventRegistration.statuses['renewed']).includes(:sy_club_member, :sadhak_profile).each do |renewed_from_reg|
      current_reg = EventRegistration.where(renewed_from: renewed_from_reg.id).includes(:sy_club_member).last
      sp = renewed_from_reg.sadhak_profile
      current_member = current_reg.try(:sy_club_member)
      data.push([sp.syid, sp.full_name, sp.mobile, sp.email, "#{current_member.try(:sy_club).try(:name)} ##{current_member.try(:sy_club_id)}", current_reg.created_at.try(:strftime, ('%b %d, %Y')), "#{(current_reg.created_at.to_date + current_reg.expires_at - 1).strftime('%b %d, %Y')}", current_reg.id, renewed_from_reg.id])
    end
    UserMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Renewed Sadhak List - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: Hash["renewed_sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(header: header, rows: data)]).deliver
  end

  desc 'Get details of refunds (stripe payments) against 629 - got 100$ per seat, need to refund half amount on email.'
  task :stripe_refund_details_629, [] => :environment do |t, args|
    data = []
    header = %w(SS_ID SS_AMOUNT SS_CHARGE_ID SS_CARD SS_STATUS ORDER_ID ACTUAL_REGISTRATION_COUNT VALID_REGISTRATION_COUNT ORDER_AMOUNT ORDER_STATUS SS_API_AVAILABLE_AMOUNT REFUND_NEEDED ACTUAL_EQUALS_TO_VALID PAYMENT_DATE)
    config_id = TransferredEventOrder.get_gateway_config_id(EventOrder.where(event_id: 629).last.id, 'stripe_config')
    StripeConfig.configure(config_id)
    StripeSubscription.joins(event_order: [:event, :event_registrations]).where(status: 1, event_orders: {event_id: 629}, event_registrations: {status: EventRegistration.valid_registration_statuses}).uniq.order('stripe_subscriptions.id ASC').includes(event_order: [:event_registrations]).each do |ss|
      eo = ss.event_order
      actual_r_count = eo.event_registrations.size
      valid_r_count = eo.event_registrations.where(status: EventRegistration.valid_registration_statuses).size
      row = [ss.id, ss.amount.to_f, ss.charge_id, ss.card, ss.status.humanize, eo.id, actual_r_count, valid_r_count, eo.total_amount.to_f, eo.status.humanize]
      ch = Stripe::Charge.retrieve(ss.charge_id)
      ss_api_amount = ((ch.amount / 100) - (ch.amount_refunded / 100)).to_f
      refund_needed = ss_api_amount > (actual_r_count * 50)
      row.push(ss_api_amount)
      row.push(refund_needed)
      row.push(actual_r_count == valid_r_count)
      row.push(ss.created_at.to_date.strftime('%d-%m-%Y-%H-%M-%S'))
      data.push(row) if refund_needed
    end
    ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Stripe Details For 629 Event - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: Hash["stripe_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(rows: data, header: header)]).deliver
  end

  desc 'Refund stripe payments against 629 - got 100$ per seat, need to refund half amount.'
  task :do_stripe_refund_629, [] => :environment do |t, args|
    data = []
    gateway = TransferredEventOrder.gateways.find {|g| g[:config_model].to_s == 'stripe_config'}
    header = %w(SS_ID SS_AMOUNT SS_CHARGE_ID SS_CARD SS_STATUS ORDER_ID ACTUAL_REGISTRATION_COUNT ORDER_AMOUNT_WAS PAYMENT_DATE TRANSACTION_LOG_ID REFUND_ID REFUNDED_AMOUNT ERROR_MESSAGE SS_API_AVAILABLE_AMOUNT_AFTER_REFUND ORDER_AMOUNT)
    config_id = TransferredEventOrder.get_gateway_config_id(EventOrder.where(event_id: 629).last.id, gateway[:config_model])
    StripeConfig.configure(config_id)
    StripeSubscription.where(id: refundable_stripe_ids).order('stripe_subscriptions.id ASC').includes(event_order: [:event_order_line_items, :event_registrations]).each do |ss|
      eo = ss.event_order
      actual_r_count = eo.event_registrations.size
      row = [ss.id, ss.amount.to_f, ss.charge_id, ss.card, ss.status.humanize, eo.id, actual_r_count, eo.total_amount.to_f, ss.created_at.to_date.strftime('%d-%m-%Y-%H-%M-%S')]

      actual_amount = ss.amount.to_f.round(2)

      other_detail = { db_refundable_amount: (actual_amount / 2).to_f.round(2), comments: "Manual refund by Prince. Email Ref: Quick task Date: Aug 17, 2016. Refunded on: #{Time.now}"}

      # Initate refund
      transaction_log = TransactionLog.create(transaction_loggable_id: ss[:event_order_id], transaction_loggable_type: 'EventOrder', other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:refund], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])

      # Update refunddable amount
      ss.amount = other_detail[:db_refundable_amount]

      payment_refund, message = (Object.const_get gateway[:controller].to_s).new.send(gateway[:refund_method].to_s.to_sym, ss, config_id, transaction_log)

      row.push(transaction_log.try(:id))

      row.push(payment_refund.try(:id))

      row.push(payment_refund.try(:amount))

      row.push(message.present? ? message : nil)

      # Update line items price and stripe subscription amount
      unless message.present?
        ss.update_columns(amount: (actual_amount - payment_refund.amount))
        eo.event_order_line_items.each do |item|
          item.update(price: 50)
        end
        total_discount = eo.valid_line_items.pluck(:discount).map { |x| x.to_f }.sum
        total_amount = eo.event_seating_category_associations.pluck(:price).map { |x| x.to_f }.sum
        eo.update_columns(total_discount: total_discount, total_amount: total_amount)
      end

      ch = Stripe::Charge.retrieve(ss.charge_id)
      ss_api_amount = ((ch.amount / 100) - (ch.amount_refunded / 100)).to_f
      row.push(ss_api_amount)

      row.push(eo.reload.total_amount.to_f)

      data.push(row)

    end
    ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Stripe Refund Details For 629 Event - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: Hash["stripe_refunds_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(rows: data, header: header)]).deliver
  end

  def refundable_stripe_ids
    return [21366, 21383, 21384, 21385, 21387, 21389, 21390, 21391, 21392, 21393, 21394, 21395, 21396, 21397, 21398, 21399, 21400, 21401, 21402, 21403, 21404, 21405, 21406, 21407, 21410, 21415, 21416, 21417, 21418, 21419, 21420, 21421, 21422, 21423, 21424, 21428, 21429, 21430, 21431, 21432, 21433, 21436, 21437, 21438, 21439, 21440, 21441, 21442, 21443, 21444, 21445, 21446, 21447, 21448, 21450, 21451, 21452, 21453, 21454, 21456, 21457, 21458, 21459, 21460, 21461, 21462, 21463, 21464, 21465, 21466, 21467, 21468, 21469, 21470, 21471, 21472, 21473, 21474, 21475, 21476, 21478, 21479, 21480, 21481, 21482, 21483, 21484, 21485, 21486, 21488, 21489, 21490, 21491, 21493, 21494, 21495, 21496, 21497, 21498, 21499, 21500, 21502, 21503, 21504, 21505, 21506, 21507, 21508]
  end

  desc 'Sadhak List with spiritual journey details.'
  task :sadhak_list_with_spiritual_journey, [:recipient, :country_id] => :environment do |t, args|
    begin
      raise 'Please input a valid email.' unless args[:recipient].present?
      sadhak_profile = SadhakProfile.last
      if args[:country_id].present?
        sadhak_profiles = SadhakProfile.joins(:address).where(addresses: {country_id: args[:country_id]})
      else
        sadhak_profiles = SadhakProfile.joins(:address).where.not(addresses: {country_id: nil})
      end
      sadhak_profiles.includes({address: [:db_country, :db_state, :db_city]}, {spiritual_journey: [{sub_source_type: [:source_info_type]}]}).find_in_batches(batch_size: 10000).with_index do |group, index|
        attachments = {}
        puts "Processing Batch: #{index+1}."
        opts = [
            {
                header_name: 'REASON_FOR_JOINING', proc: Proc.new{|p| p.try(:spiritual_journey).try(:reason_for_joining)}
            },
            {
                header_name: 'FIRST_EVENT_ATTENDED(PLACE)', proc: Proc.new{|p| p.try(:spiritual_journey).try(:first_event_attended)}
            },
            {
                header_name: 'FIRST_EVENT_ATTENDED(MONTH)', proc: Proc.new{|p| p.try(:spiritual_journey).try(:first_event_attended_month)}
            },
            {
                header_name: 'FIRST_EVENT_ATTENDED(YEAR)', proc: Proc.new{|p| p.try(:spiritual_journey).try(:first_event_attended_year)}
            },
            {
                header_name: 'SOURCE_OF_INFORMATION', proc: Proc.new{|p| p.try(:spiritual_journey).try(:source_info_type).try(:source_name)}
            },
            {
                header_name: 'SOURCE_OF_INFORMATION(MEDIA)', proc: Proc.new{|p| p.try(:spiritual_journey).try(:sub_source_type).try(:sub_source_name)}
            },
            {
                header_name: 'ALTERNATIVE_SOURCE', proc: Proc.new{|p| p.try(:spiritual_journey).try(:alternative_source)}
            }
        ]
        # Generate profiles data.
        file = GenerateExcel.generate(GenerateSadhakProfilesExcel.call(group, nil, opts))
        attachments["#{index+1}_sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = file
        ApplicationMailer.send_email(recipients: args[:recipient], subject: "Sadhak List #{index+1} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}.", attachments: attachments).deliver
      end
    rescue Exception => e
      Rollbar.error(e)
      Rails.logger.info(e.message)
    end
  end


  desc 'Move Given sadhak profiles to a given event.'
  task :sadhak_migration_to_event, [:event_id, :sadhak_profile_ids] => :environment do |t, args|
    begin
      processed_sadhak_ids = []

      # Find event
      event = Event.find_by_id(args[:event_id])
      raise 'Please input a valid event id' unless event.present?

      input_sadhak_ids = args[:sadhak_profile_ids].try(:split, ('-')) || []
      raise 'Please input sadhak profiles' unless input_sadhak_ids.present?

      # Collect event data
      event_seating_category_association = event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id
      event_seating_category_association_id = event_seating_category_association.id
      price = event_seating_category_association.price

      # Find already registered sadhak profile ids
      registered_sadhak_ids = event.event_registrations.where(status: EventRegistration.valid_registration_statuses).pluck(:sadhak_profile_id).uniq

      input_sadhak_ids = input_sadhak_ids.map{|id| id.to_i}

      SadhakProfile.where(id: (input_sadhak_ids - registered_sadhak_ids)).find_in_batches(batch_size: 10) do |group|
        # Create event order and registrations
        ActiveRecord::Base.transaction do

          @event_order = EventOrder.new(event_id: event.id, guest_email: 'syitemails@gmail.com', is_guest_user: true, payment_method: 'No Payment')
          raise @event_order.errors.full_messages.first unless @event_order.save

          group.each do |sadhak_profile|

            next if (processed_sadhak_ids + registered_sadhak_ids).include?(sadhak_profile.id)

            @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile.id, seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price)

            raise @event_order_line_item.errors.full_messages.first unless @event_order_line_item.save

            EventRegistration.without_callbacks(:notify_registration) do
              @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile.id, event_seating_category_association_id: event_seating_category_association_id, event_id: event.id, event_order_line_item_id: @event_order_line_item.id)
              raise @event_registration.errors.full_messages.first unless @event_registration.save
            end

            processed_sadhak_ids.push(sadhak_profile.id)

            # sadhak_profile_id-event_order_id-event_registration_id-item_id
            puts "#{sadhak_profile.id}-#{@event_order.id}-#{@event_registration.id}-#{@event_order_line_item.id}"

          end

          # Update event order
          if @event_order.event_registrations.size > 0
            status = EventOrder.statuses['success']
            is_deleted = false
          else
            status = EventOrder.statuses['pending']
            is_deleted = true
          end
          @event_order.update_columns(status: status, is_deleted: is_deleted, transaction_id: "Offline-#{Time.now.strftime('%d%m%Y%H%M%S%N')}")
        end
      end

    rescue => e
      Rollbar.error(e)
    end
  end

  desc 'Create transfer entries.'
  task :create_sy_club_member_action_entries, [] => :environment do |t, args|
    begin
      sy_club_members = SyClubMember.unscoped.where.not(event_registration_id: nil)
      transferred_members = SyClubMember.unscoped.where.not(event_registration_id: nil).where(status: SyClubMember.statuses['transferred']).order(:id).includes(:event_registration)
      processed_member_ids = SyClubMemberActionDetail.where(from_sy_club_member_id: transferred_members.pluck(:id)).pluck(:from_sy_club_member_id)
      ActiveRecord::Base.transaction do
        transferred_members.each do |t_member|

          next if processed_member_ids.include?(t_member.id)

          puts "Processing Member ID: #{t_member.id}."

          new_sy_club_member = sy_club_members.find{|m| m.sadhak_profile_id == t_member.sadhak_profile_id and m.metadata == "Transferred_from_member_id: #{t_member.id}."}

          raise "Transferred entry not found for member id: #{t_member.id}" unless new_sy_club_member.present?

          from_event_registration = t_member.event_registration
          raise "From Registration not found: #{t_member.id}" unless from_event_registration.present?

          to_event_registration = new_sy_club_member.event_registration
          raise "To Registration not found: #{t_member.id}" unless to_event_registration.present?

          raise "Both event registration id mismatch: from: #{t_member.id}, to: #{new_sy_club_member.id}" if from_event_registration.id != to_event_registration.id

          SyClubMemberActionDetail.without_callbacks(:is_transfer_in_out_club_enabled?) do
            sy_club_member_action_detail = SyClubMemberActionDetail.new(action_type: SyClubMemberActionDetail.action_types['transfer'], sadhak_profile_id: t_member.sadhak_profile_id, from_sy_club_member_id: t_member.id, to_sy_club_member_id: new_sy_club_member.id, from_event_registration_id: from_event_registration.id, to_event_registration_id: to_event_registration.id, action_time: new_sy_club_member.created_at)

            raise SyException, sy_club_member_action_detail.errors.full_messages.first unless sy_club_member_action_detail.save
            raise SyException, sy_club_member_action_detail.errors.full_messages.first unless sy_club_member_action_detail.update(status: SyClubMemberActionDetail.statuses['approved'])
          end
          processed_member_ids.push(t_member.id)
        end
      end
    rescue => e
      Rollbar.error(e)
    end
  end

  desc 'Send list of board members who not paid.'
  task :not_paid_board_members_list, [] => :environment do |t, args|
    data = []
    header = %w(FORUM_ID FORUM_NAME SADHAK_ID SADHAK_NAME ROLE)
    sy_clubs = SyClub.all
    SyClubSadhakProfileAssociation.joins(:sy_club).where(sy_clubs: {is_deleted: false}).includes({sadhak_profile: [:forum_memberships]}, :sy_club_user_role, :sy_club).group_by(&:sy_club_id).each do |club_id, bms|
      sy_club = sy_clubs.find{|c| c.id == club_id}
      next unless sy_club.present?
      bms.each do |bm|
        sp = bm.sadhak_profile
        next unless sp.present?
        next if sp.active_club_ids.size > 0
        data.push([sy_club.id, sy_club.name, sp.syid, sp.full_name, bm.try(:sy_club_user_role).try(:role_name)])
      end
    end

    ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Board Members List (Not Paid)- #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: {"board_members_not_paid_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls" => GenerateExcel.generate(rows: data, header: header)}).deliver
  end

  desc 'Sadhak List with professional and source of information details.'
  task :sadhak_list_with_professional_and_source_of_info, [:recipient] => :environment do |t, args|
    begin
      raise 'Please input a valid email.' unless args[:recipient].present?
      sadhak_profile = SadhakProfile.last
      SadhakProfile.joins(:address).includes({address: [:db_country, :db_state, :db_city]}, {spiritual_journey: [{sub_source_type: [:source_info_type]}]}, {professional_detail: [:profession]}).find_in_batches(batch_size: 10000).with_index do |group, index|
        attachments = {}
        puts "Processing Batch: #{index+1}."
        next if index <= 4
        opts = [
            {
                header_name: 'EDUCATIONAL_QUALIFICATION', proc: Proc.new{|p| p.try(:professional_detail).try(:highest_degree)}
            },
            {
                header_name: 'PROFESSION', proc: Proc.new{|p| p.try(:professional_detail).try(:profession).try(:name)}
            },
            {
                header_name: 'OCCUPATION', proc: Proc.new{|p| p.try(:professional_detail).try(:occupation)}
            },
            {
                header_name: 'SOURCE_OF_INFORMATION', proc: Proc.new{|p| p.try(:spiritual_journey).try(:source_info_type).try(:source_name)}
            },
            {
                header_name: 'SOURCE_OF_INFORMATION(MEDIA)', proc: Proc.new{|p| p.try(:spiritual_journey).try(:sub_source_type).try(:sub_source_name)}
            },
            {
                header_name: 'ALTERNATIVE_SOURCE', proc: Proc.new{|p| p.try(:spiritual_journey).try(:alternative_source)}
            }
        ]
        # Generate profiles data.
        file = GenerateExcel.generate(GenerateSadhakProfilesExcel.call(group, nil, opts))
        attachments["#{index+1}_sadhak_list_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = file
        ApplicationMailer.send_email(recipients: args[:recipient], subject: "Sadhak List #{index+1} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}.", attachments: attachments).deliver
      end
    rescue Exception => e
      Rollbar.error(e)
      Rails.logger.info(e.message)
    end
  end

  desc "Reminder email and SMS to sadhaks who's profile photo and photo id is rejected."
  task :reminder_email_sms_to_profile_photo_and_photo_id_rejected, [] => :environment do |t, args|
    begin

      # Get custom messages rejection sms content and rejection email content filled by admin.
      default_text = 'Your Photo or Photo ID is rejected. Please make sure to upload correct and clear photo and photo ID. Please make sure that picture of your face is clearly visible in your photo.'

      default_email_subject = 'Photo and Photo ID Rejected.'

      email_text = GlobalPreference.get_value_of('photo_and_photo_id_rejection_email_text')

      sms_text = GlobalPreference.get_value_of('photo_and_photo_id_rejection_sms_text')

      email_subject = GlobalPreference.get_value_of('photo_and_photo_id_rejection_email_subject')

      email_text ||= default_text

      sms_text ||= default_text

      email_subject ||= default_email_subject

      # Select sadhak profile with profile photo status as rejected or photo id status rejected
      SadhakProfile.where('profile_photo_status = ? AND photo_id_status = ?', SadhakProfile.profile_photo_statuses.pp_rejected, SadhakProfile.photo_id_statuses.pi_rejected).find_in_batches(batch_size: 1000).each_with_index do |group, group_index|

          group.each_with_index do |sadhak_profile, index|

            # Notify by Email
            from = GetSenderEmail.call(sadhak_profile)

            begin
              ApplicationMailer.send_email(from: from, recipients: sadhak_profile.email, subject: email_subject, template: 'sadhak_profile_photo_and_photo_id_proof_rejection_notification', sadhak_profile: sadhak_profile, email_text: email_text).deliver_now if sadhak_profile.email.is_valid_email?
            rescue Exception => e
              Rails.logger.info("Exception: Task: reminder_email_sms_to_profile_photo_and_photo_id_rejected: sadhak_profile: #{sadhak_profile.id}: Email sending error: #{e.message}")
            end

            begin
              # Notify by SMS
              sadhak_profile.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\n#{sms_text}")
            rescue Exception => e
              Rails.logger.info("Exception: Task: reminder_email_sms_to_profile_photo_and_photo_id_rejected: sadhak_profile: #{sadhak_profile.id}: SMS sending error: #{e.message}")
            end

          end

      end

    rescue => e
      Rollbar.error(e)
    end

  end

  desc 'Stripe payment refund, Email Ref: Fwd: List of Sadhaks not received discount in Live Shivir with their Shivir name Date: April 20, 2017'
  task :stripe_discount_refund, [] => :environment do |t, args|

    event_id = 884

    sids = [99817, 138739, 97196, 33004, 100003, 72423, 70812, 31498, 77715]

    # event_id = 883

    # sids = [71848]

    # event_id = 857

    # sids = [115956]

    EventRegistration.where(event_id: event_id, sadhak_profile_id: sids, status: EventRegistration.valid_registration_statuses).collect{|r| [r.sadhak_profile_id, r.event_order.reg_ref_number, r.event_order.stripe_subscriptions.pluck(:id), r.event_order.transaction_logs.size] }

    data = []

    gateway = TransferredEventOrder.gateways.find {|g| g[:config_model].to_s == 'stripe_config'}

    header = %w(REGISTRATION_ID EVENT_ID SADHAK_PROFILE_ID SS_ID SS_AMOUNT SS_CHARGE_ID SS_CARD SS_STATUS ORDER_ID ORDER_AMOUNT_WAS PAYMENT_DATE TRANSACTION_LOG_ID REFUND_ID REFUNDED_AMOUNT ERROR_MESSAGE SS_API_AVAILABLE_AMOUNT_AFTER_REFUND ORDER_AMOUNT)

    EventRegistration.where(event_id: event_id, sadhak_profile_id: sids, status: EventRegistration.valid_registration_statuses).each do |r|

      eo = r.event_order

      config_id = TransferredEventOrder.get_gateway_config_id(eo.id, gateway[:config_model])

      StripeConfig.configure(config_id)

      ss = eo.stripe_subscriptions.last

      row = [r.id, r.event_id, r.sadhak_profile_id, ss.id, ss.amount.to_f, ss.charge_id, ss.card, ss.status.humanize, eo.id, eo.total_amount.to_f, ss.created_at.to_date.strftime('%d-%m-%Y-%H-%M-%S')]

      actual_amount = ss.amount

      category_price = r.event_seating_category_association.price

      other_detail = { db_refundable_amount: (category_price / 2).to_f.round(2), comments: "Manual refund by Prince. Email Ref: Fwd: List of Sadhaks not received discount in Live Shivir with their Shivir name Date: April 20, 2017. Refunded on: #{Time.now}", config_id: config_id, sadhak_profile_id: r.sadhak_profile_id}

      # Initate refund
      transaction_log = TransactionLog.create(transaction_loggable_id: eo.id, transaction_loggable_type: 'EventOrder', other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:refund], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])

      # Update refunddable amount
      ss.amount = other_detail[:db_refundable_amount]

      payment_refund, message = (Object.const_get gateway[:controller].to_s).new.send(gateway[:refund_method].to_s.to_sym, ss, config_id, transaction_log)

      row.push(transaction_log.try(:id))

      row.push(payment_refund.try(:id))

      row.push(payment_refund.try(:amount))

      row.push(message.present? ? message : nil)

      # Update line items price and stripe subscription amount
      unless message.present?
        ss.update_columns(amount: (actual_amount - payment_refund.amount))
        r.event_order_line_item.update(price: category_price, discount: category_price/2)
      end

      ch = Stripe::Charge.retrieve(ss.charge_id)
      ss_api_amount = ((ch.amount / 100) - (ch.amount_refunded / 100)).to_f
      row.push(ss_api_amount)

      row.push(eo.reload.total_amount.to_f)

      data.push(row)

    end

    ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Stripe Refund Email: List of Sadhaks not received discount in Live Shivir with their Shivir name - Event ID: #{event_id} - SYIDS: #{sids.join(';')}", attachments: Hash["stripe_refunds_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(rows: data, header: header)]).deliver

  end

  # rake admin:mark_registrations_cancelled["stripe_refunded_payments_mark_reg_cancel.csv"]
  desc 'Mark registrations cancelled as amount refunded manually (Stripe)'
  task :mark_registrations_cancelled, [:filename] => :environment do |t, args|

    Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

    data = read_csv(@file)

    header = %w(SADHAK_PROFILE_ID REGISTRATION_ID EVENT_ORDER_ID EVENT_ID REGISTRATION_STATUS SS_ID)

    rows = []

    gateway = TransferredEventOrder.gateways.find {|g| g[:config_model].to_s == 'stripe_config'}

    ActiveRecord::Base.transaction do

      begin

        cal = []

        gouped_data = data[:content].group_by{|c| c[:"event_order_id (metadata)"]}

        gouped_data.each do |event_order_id, rs|


          total_refunded_amount = rs.collect{|r| r[:"amount refunded"].to_f}.sum

          total_paid_amount = TransactionLog.where(id: rs.collect{|r| r[:"transaction_log_id (metadata)"]}).collect{|tl| tl.other_detail['amount'].to_f}.sum

          cal << [total_refunded_amount, total_paid_amount]

        end

        data[:content].each_with_index do |r, i|

          ss = StripeSubscription.find_by_customer_id(r[:"customer id"])

          eo = ss.event_order

          p "Processing event order: #{eo.id}"

          config_id = TransferredEventOrder.get_gateway_config_id(eo.id, gateway[:config_model])

          StripeConfig.configure(config_id)

          ch = Stripe::Charge.retrieve(r[:id])

          other_detail = eo.other_detail.merge({
            message: "Refund made by Admin from stripe site. We are syncing refunds with event registrations. Email Ref: payment bug from Jay Date: 27 April 2017 IST (+5:30)",
            total_refunded_amount: ch.amount_refunded.to_f/100
          })

          ch.refunds.data.as_json.each do |refund|

            transaction_log = TransactionLog.create(transaction_loggable_id: eo.id, transaction_loggable_type: 'EventOrder', other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:refund], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])

            transaction_log.update_attributes(gateway_request_object: ss.as_json[gateway[:model].underscore], gateway_response_object: refund, gateway_transaction_id: refund['id'], status: 'success')

            ss.update_attributes(amount: ss.amount.to_f - (refund['amount'].to_f/100))

          end

          eo.event_order_line_items.each do |item|

            item.update(status: EventOrderLineItem.statuses.cancelled_refunded)

            item.event_registration.update(status: EventRegistration.statuses.cancelled_refunded)

            rows << [item.sadhak_profile_id, item.event_registration.id, eo.id, eo.event_id, item.event_registration.status, ss.id]
          end

        end

        ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Mark registration cancelled for stripe payments refunded by admin", attachments: Hash["cancelled_registrations_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(rows: rows, header: header)]).deliver if rows.size > 0

      rescue => e
        Rollbar.error(e)
      end

    end

  end

  desc 'Refund stripe payments'
  task :do_stripe_refund, [:filename] => :environment do |t, args|

    data = []

    gateway = TransferredEventOrder.gateways.find {|g| g[:config_model].to_s == 'stripe_config'}

    header = %w(SS_ID SS_AMOUNT SS_CHARGE_ID SS_CARD SS_STATUS ORDER_ID PAYMENT_DATE TRANSACTION_LOG_(REFUND)_ID STRIPE_REFUND_ID REFUNDED_AMOUNT ERROR_MESSAGE SS_API_AVAILABLE_AMOUNT_AFTER_REFUND)

    Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])

    records = read_xls(@file)

    raise 'Header Columns missing' unless records[:header].include?('event_order_id') && records[:header].include?('amount_needs_to_be_refunded') && records[:header].include?('charge_id') && records[:header].include?('comment')

    row = []

    begin
      records[:content].each do |r|

        eo = EventOrder.find(r[:event_order_id])

        ss = StripeSubscription.find_by_charge_id(r[:charge_id])

        raise "No stripe subscription found - Charge Id: #{r[:charge_id]}" unless ss.present?

        row = [ss.id, ss.amount.to_f, ss.charge_id, ss.card, ss.status.humanize, eo.id, ss.created_at.strftime('%d-%m-%Y-%H-%M-%S')]

        other_detail = { db_refundable_amount: r[:amount_needs_to_be_refunded].to_f.round(2), comments: "#{r[:comment]}. Refunded on: #{Time.now}"}

        next if other_detail[:db_refundable_amount] == 0

        config_id = TransferredEventOrder.get_gateway_config_id(eo.id, gateway[:config_model])

        raise "No config id found - Charge Id: #{ss.charge_id}" unless config_id.present?

        StripeConfig.configure(config_id)

        transaction_log = TransactionLog.create(transaction_loggable_id: eo.id, transaction_loggable_type: 'EventOrder', other_detail: other_detail, transaction_type: TransactionLog.transaction_types[:refund], gateway_type: gateway[:gateway_type], gateway_name: gateway[:symbol])

        actual_amount = ss.amount.to_f.round(2)

        # Update refunddable amount
        ss.amount = other_detail[:db_refundable_amount]

        payment_refund, message = StripeSubscription.send(gateway[:refund_method].to_s.to_sym, ss, config_id, transaction_log)

        row << transaction_log.try(:id)

        row << payment_refund.try(:id)

        row << payment_refund.try(:amount).to_f.round(2)

        row << message.to_s

        # Update stripe subscription amount
        ss.update_columns(amount: (actual_amount - payment_refund.try(:amount).to_f.round(2))) unless message.present?

        ch = Stripe::Charge.retrieve(ss.charge_id)

        ss_api_amount = ((ch.amount.to_f / 100) - (ch.amount_refunded.to_f / 100)).to_f.round(2)

        row << ss_api_amount

        data << row

      end
    rescue => e
      Rollbar.error(e)
    end

    ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, subject: "Stripe Refund Details - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: Hash["stripe_refunds_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(rows: data, header: header)]).deliver

  end

  desc "Send event refund details"
  task :send_event_order_list_with_refundable_amount_for_events, [:event_ids, :recipients] => :environment  do |t, args|
    raise 'Event ids cannot be blank.' unless args[:event_ids].present?
    raise 'Please input recipients.' unless args[:recipients].present?
    recipients = args[:recipients].split('-').extract_valid_emails
    raise 'Please input valid recipients.' unless recipients.present?
    events = Event.where(id: args[:event_ids].split('-'))
    raise 'Please input a valid event ids.' unless events.present?
    data = []
    header = %w(EVENT_ID EVENT_ORDER_ID  REFERENCE_NO SYIDS REG_IDS PAYMENT_METHODS TRANSACTION_ID TOTAL_REFUNDABLE_AMOUNT)
    (events || []).each do |event|
      valid_event_orders_ids = event.valid_event_registrations.pluck(:event_order_id).uniq
      valid_event_orders = EventOrder.where(id: valid_event_orders_ids)

      (valid_event_orders || []).each do |ev_order|
         row = []
         row.push(ev_order.event_id)
         row.push(ev_order.id)
         row.push(ev_order.reg_ref_number)
         row.push(ev_order.registered_sadhak_profiles.pluck(:syid).join(','))
         row.push(ev_order.valid_event_registrations.ids.join(','))

         total_refundable_amount = 0.0
        payment_methods = []
         TransferredEventOrder.gateways.each do |g|
           (Object.const_get g.model).where(event_order_id: ev_order.id, status: g[:success]).each do |pt|
             total_refundable_amount += pt.amount
             payment_methods << g.payment_method
           end
        end

         row.push(payment_methods.join(','))
         row.push(ev_order.transaction_id)
         row.push('%.2f' % total_refundable_amount.to_f)
         data.push(row)
       end
       ApplicationMailer.send_email(recipients: recipients, subject: "Event's refund details - #{event.event_name} - #{event.id}", attachments: { "#{event.id}_#{event.event_name.parameterize.underscore}_refund_details.xls" => GenerateExcel.generate(header: header, rows: data)}).deliver
    end
  end

end
