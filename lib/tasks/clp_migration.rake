namespace :clp_migration do
  # task :clp_data_migration, [:price, :seating_category_id, :seating_association_id, :event_id] => :environment do |t, args|
  task clp_data_migration: :environment do
    begin
      last_run_at = GlobalPreference.get_value_of('clp_migration_last_run')
      errors = []
      sadhak_ids = []
      event_id = 540 #args[:event_id]
      seating_category_id = 18 #args[:seating_category_id]
      event_seating_category_association_id = 98 #args[:seating_association_id]
      price = 50 #args[:price]
      members = SyClubMember.includes(:sadhak_profile, :sy_club).where("status = ? and updated_at > ?", SyClubMember.statuses["approve"], last_run_at.to_date).group(:transaction_id).count
      if members.present? and members.count > 0
        members.each do |key, value|
          if key.present?
            sadhaks = SyClubMember.where('transaction_id = ? and status = ? and updated_at > ?', key, SyClubMember.statuses['approve'], last_run_at.to_date)
          else
            sadhaks = SyClubMember.where('transaction_id IS ? and status = ? and updated_at > ?', key, SyClubMember.statuses['approve'], last_run_at.to_date)
          end
          next unless sadhaks.present?
          # sadhaks = SyClubMember.where(transaction_id: key, status: SyClubMember.statuses["approve"])
          @guest_email = sadhaks.first.guest_email
          sadhak_ids = sadhaks.pluck(:sadhak_profile_id)
          ActiveRecord::Base.transaction do
            if sadhak_ids.present? and sadhak_ids.count > 0
              @event_order = EventOrder.new(event_id: event_id, guest_email: @guest_email, is_guest_user: true, payment_method: 'Stripe Payment', transaction_id: key, status: 'success')
              if @event_order.save
                sadhak_ids.each do |sadhak|
                  sadhak_profile_id = sadhak
                  @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price)
                  if @event_order_line_item.save
                    puts "event_order_line_item ID"
                    puts @event_order_line_item.id
                    registration = EventRegistration.where(sadhak_profile_id: sadhak_profile_id, event_id: event_id).last
                    if registration.present?
                      puts "Profile already registered"
                    else
                      @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: event_seating_category_association_id, event_id: event_id, event_order_line_item_id: @event_order_line_item.id)
                      if @event_registration.save
                        puts "event registration created successfully"
                        puts @event_registration.id
                      else
                        errors.push(["event registration error", sadhak_profile_id, event_id].to_s)
                        puts "event registration error"
                      end
                    end
                  else
                    errors.push(["Error in line item", @event_order_line_item.id].to_s)
                    puts "Error in line item"
                  end
                end
              end
            else
              puts "No valid profile found"
            end
          end
        end
      else
        puts "No members registration found"
      end
      # Set last clp migration run
      GlobalPreference.set_value_of('clp_migration_last_run', DateTime.now)
    rescue => e
      Rollbar.error(e)
    end
    if errors.present? and errors.count > 0
      puts errors
    else
      puts "No error found"
    end
  end

  task :forum_organizers_migration_to_event, [:event_id, :sadhak_profile_ids] => :environment do |t, args|
    begin
      processed_sadhak_ids = []

      # Find event
      event = Event.find_by_id(args[:event_id])
      raise 'Please input a valid event id' unless event.present?

      # Collect event data
      event_seating_category_association = event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id
      event_seating_category_association_id = event_seating_category_association.id
      price = event_seating_category_association.price

      # Find already registered sadhak profile ids
      registered_sadhak_ids = event.event_registrations.where(status: EventRegistration.valid_registration_statuses).pluck(:sadhak_profile_id).uniq

      if args[:sadhak_profile_ids].present?
        sy_club_sadhak_associations = SyClubSadhakProfileAssociation.where.not(sy_club_user_role_id: nil).where(sadhak_profile_id: args[:sadhak_profile_ids].split('-')).order('created_at ASC').includes(:sadhak_profile, :sy_club)
      else
        sy_club_sadhak_associations = SyClubSadhakProfileAssociation.where.not(sy_club_user_role_id: nil, sadhak_profile_id: registered_sadhak_ids).order('created_at ASC').includes(:sadhak_profile, :sy_club)
      end

      sy_club_sadhak_associations.group_by(&:sy_club_id).each do |sy_club_id, organizers|

        # Sort organisers according to role id
        organizers = organizers.sort_by(&:sy_club_user_role_id)

        # Get forum
        sy_club = SyClub.find_by_id(sy_club_id)

        # Next if not found
        next unless sy_club.present?

        sadhak_ids = organizers.collect{|o| o.sadhak_profile_id}

        next if (processed_sadhak_ids & sadhak_ids).size == sadhak_ids.size

        # Create event order and registrations
        ActiveRecord::Base.transaction do

          @event_order = EventOrder.new(event_id: event.id, guest_email: organizers.first.try(:sadhak_profile).try(:email), is_guest_user: true, payment_method: 'No Payment')
          raise @event_order.errors.full_messages.first unless @event_order.save

          organizers.each do |organiser|

            next if (processed_sadhak_ids + registered_sadhak_ids).include?(organiser.sadhak_profile_id)

            @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: organiser.sadhak_profile_id, seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price)

            raise @event_order_line_item.errors.full_messages.first unless @event_order_line_item.save

            EventRegistration.without_callbacks(:notify_registration) do
              @event_registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: organiser.sadhak_profile_id, event_seating_category_association_id: event_seating_category_association_id, event_id: event.id, event_order_line_item_id: @event_order_line_item.id)
              raise @event_registration.errors.full_messages.first unless @event_registration.save
            end

            processed_sadhak_ids.push(organiser.sadhak_profile_id)

            # sadhak_profile_id-event_order_id-event_registration_id-item_id
            puts "#{organiser.sadhak_profile_id}-#{@event_order.id}-#{@event_registration.id}-#{@event_order_line_item.id}"

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

      # Remove profiles that are not currently as board members
      # organisers_sadhak_ids = SyClubSadhakProfileAssociation.where.not(sy_club_user_role_id: nil).pluck(:sadhak_profile_id).uniq
      # existing_sadhak_ids = event.event_registrations.where(status: EventRegistration.valid_registration_statuses).pluck(:sadhak_profile_id).uniq
      #
      # registartions = event.event_registrations.where(sadhak_profile_id: (existing_sadhak_ids - organisers_sadhak_ids), status: EventRegistration.valid_registration_statuses)
      #
      # registartions.update_all(is_deleted: true)
      #
      # EventOrderLineItem.where(id: registartions.collect{|r| r.event_order_line_item_id}).update_all(is_deleted: true)

    rescue => e
      Rollbar.error(e)
    end
  end

  desc 'Nightly script to expire clp membership and send email to sadhak informing about their membership.'
  task mark_clp_members_expired_and_send_email: :environment do
    begin
      success = []
      success_header = %w(SADHAK_PROFILE_ID EVENT_ID REGISTRATION_ID REGISTRATION_STATUS_WAS REGISTRATION_STATUS RENEWAL_LINK DAYS FORUM_MEMBER_ID FORUM_MEMBER_STATUS_WAS FORUM_MEMBER_STATUS FORUM_ID EMAIL_RECIPIENTS EMAIL_SENT EMAIL_ERROR MESSAGE)

      india_event_ids = GlobalPreference.get_value_of('india_clp_events').to_s.split(',')

      global_event_ids = GlobalPreference.get_value_of('global_clp_events').to_s.split(',')

      global_renewal_link = GlobalPreference.get_value_of('global_clp_renewal_link').to_s

      india_renewal_link = GlobalPreference.get_value_of('india_clp_renewal_link').to_s

      banned_forum_sadhaks = GlobalPreference.get_value_of('banned_forum_sadhaks').to_s.split(',').map { |syid| syid.to_s[/-?\d+/].to_i  }

      EventRegistration.joins(:sy_club_member).where(event_registrations: {status: EventRegistration.valid_registration_statuses, event_id: (india_event_ids + global_event_ids)}).where.not(sy_club_members: {event_registration_id: [nil]}).includes({sadhak_profile: [:user]}, {sy_club_member: [:sy_club]}, :event).find_each(batch_size: 1) do |registration|

        begin

          days = ((registration.created_at.to_date + registration.expires_at.to_i) - Date.today).to_i

          sadhak_profile = registration.sadhak_profile

          sy_club_member = registration.sy_club_member

          sy_club = sy_club_member.try(:sy_club)

          event = registration.try(:event)

          # Don't send email and sms if sadhak is banned from event or from forums.
          next if !sadhak_profile.present?

          is_banned = sadhak_profile.banned? || banned_forum_sadhaks.include?(sadhak_profile.id)

          # Run to mark registration and members as expired if they are failed to expired
          if days <= 0 and registration.present? and sy_club_member.present? and not registration.renewed? and not sy_club_member.renewed?

            success.push([sadhak_profile.id, registration.event_id, registration.id, registration.status, nil, nil, days, sy_club_member.id, sy_club_member.status, nil, sy_club.try(:id), nil, nil, nil, 'Silently updating status of registration and member'])

            registration.update_columns(status: EventRegistration.statuses['expired']) unless registration.expired?
            sy_club_member.update_columns(status: SyClubMember.statuses['expired']) unless sy_club_member.expired?

            found = success.find{|s| s[0] == sadhak_profile.id and s[2] == registration.id and s[7] == sy_club_member.id}

            if found.present?
              found[success_header.index('REGISTRATION_STATUS')] = registration.status
              found[success_header.index('FORUM_MEMBER_STATUS')] = sy_club_member.status
            end
          end

          next if (days > 30 or days < 0)

          if india_event_ids.include?(registration.event_id.to_s)
            link = "#{india_renewal_link}/#{sy_club.slug}/register"
            visit_website_link = "#{Rails.application.config.app_base_url}"
          elsif global_event_ids.include?(registration.event_id.to_s)
            link = "#{global_renewal_link}/#{sy_club.slug}/register"
            visit_website_link = "#{Rails.application.config.app_base_url}"
          else
            link = 'NA'
          end

          if sadhak_profile.present? and sy_club_member.present? and sy_club.present?
            # Send expiry email
            if [0, 1, 7, 30].include?(days)
              begin
                if days > 0
                  subject = "Membership with #{sy_club.name} is going to expire on #{(registration.created_at.to_date + registration.expires_at.to_i - 1).to_s} at 23:59:00"
                else
                  subject = "Membership with #{sy_club.name} has been expired."
                end

                recipients = [sadhak_profile.try(:email), sadhak_profile.try(:user).try(:email)].uniq

                message = is_banned ? 'Banned Sadhak Profile.' : nil

                from = GetSenderEmail.call(event)

                expiry_message = "Your Membership with <b> #{sy_club.name} </b> "

                expiry_message += if days > 0 then
                  "is going to expire on <b>#{(registration.created_at.to_date + registration.expires_at.to_i - 1).to_s}</b> at <b>23:59:00</b>."
                else
                  'has been <b>expired</b>.'
                end

                begin
                  ApplicationMailer.send_email(from: from, recipients: recipients, subject: subject, template: 'forum_membership_renewal', link: link, sadhak_profile: sadhak_profile, visit_website_link: visit_website_link, expiry_message: expiry_message).deliver unless is_banned
                rescue AWS::SES::ResponseError => e
                  message = e.message
                end

                success.push([sadhak_profile.id, registration.event_id, registration.id, registration.status, nil, link, days, sy_club_member.id, sy_club_member.status, nil, sy_club.id, recipients.join(','), message.nil?, message, nil])

              rescue => e
                Rails.logger.info("Something went while sending membership expire email to in method: mark_clp_members_expired_and_send_email, error: #{e.message}")
                Rollbar.error(e)
              end
            end

            if days == 0
              registration.update_columns(status: EventRegistration.statuses['expired'])
              sy_club_member.update_columns(status: SyClubMember.statuses['expired'])

              found = success.find{|s| s[0] == sadhak_profile.id and s[2] == registration.id and s[7] == sy_club_member.id}

              if found.present?
                found[success_header.index('REGISTRATION_STATUS')] = registration.status
                found[success_header.index('FORUM_MEMBER_STATUS')] = sy_club_member.status
              end
            end
          end

        rescue => e
          Rails.logger.error("Some error occured in mark_clp_members_expired_and_send_email - inside block of code: #{e.message}")
          Rollbar.error(e)
        end
      end

      begin
        EventRegistration.generate_excel_and_upload(rows: success, header: success_header, file_name: "clp_migration-mark_clp_members_expired_and_send_email-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/clp_migration/mark_clp_members_expired_and_send_email") if success.size > 0
      rescue => e
        Rails.logger.error("Some error occured while uploading file mark_clp_members_expired_and_send_email: #{e.message}")
        Rollbar.error(e)
      end
    rescue => e
      Rails.logger.error("Some error occured in mark_clp_members_expired_and_send_email: #{e.message}")
      Rollbar.error(e)
    end
  end

  task india_global_clp_data_migration: :environment do
    begin
      last_run_at = '2012-01-01'
      errors = []
      success = []
      unmigrated = []
      joining_date_missing_profiles = []

      india_event_id = GlobalPreference.get_value_of('india_clp_events').to_s.split(',').first
      global_event_id = GlobalPreference.get_value_of('global_clp_events').to_s.split(',').first

      # We are moving data to clp product so it will automatic consider 1st seating category for data movement.
      india_event = Event.find(india_event_id)
      global_event = Event.find(global_event_id)

      event_seating_category_association = india_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details = Hash.new
      details[:india] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id}

      event_seating_category_association = global_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details[:global] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id}

      grouped_members = SyClubMember.includes(:sadhak_profile, :sy_club).where('status = ? and event_registration_id IS ? and updated_at > ?', SyClubMember.statuses['approve'], nil, last_run_at.to_date).group(:transaction_id).count

      # grouped_members = SyClubMember.includes(:sadhak_profile, :sy_club).where('status = ? and updated_at > ?', SyClubMember.statuses['approve'], last_run_at.to_date).group(:transaction_id).count.first(10)

      sy_clubs = SyClub.unscoped.all

      if grouped_members.present? and grouped_members.count > 0
        grouped_members.each do |key, value|
          if key.present?
            sy_members = SyClubMember.where('transaction_id = ? and status = ? and event_registration_id IS ? and updated_at > ?', key, SyClubMember.statuses['approve'], nil, last_run_at.to_date).order(:id)
          else
            sy_members = SyClubMember.where('transaction_id IS ? and status = ? and event_registration_id IS ? and updated_at > ?', key, SyClubMember.statuses['approve'], nil, last_run_at.to_date).order(:id)
          end

          next unless sy_members.present?
          sy_members.group_by(&:sy_club_id).each do |sy_club_id, members|
            sy_club = sy_clubs.find{|s| s.id == sy_club_id}
            puts "Processing SyClub: #{sy_club_id}."
            @guest_email = members.first.guest_email
            if sy_club.present? and sy_club.address.present?
              if sy_club.address.country_id == 113
                detail = details[:india]
              else
                detail = details[:global]
              end
            else
              # raise "#{sy_club.name}:#{sy_club.id} address not found."
              unmigrated += members
              next
            end

            ActiveRecord::Base.transaction do
              if members.present? and members.count > 0

                @event_order = EventOrder.new(event_id: detail[:event_id], guest_email: @guest_email, is_guest_user: true, payment_method: members.first.payment_method, transaction_id: key)

                if @event_order.save

                  members.each do |member|

                    sadhak_profile_id = member.sadhak_profile_id

                    @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: detail[:seating_category_id], event_seating_category_association_id: detail[:event_seating_category_association_id], price: detail[:price])

                    if @event_order_line_item.save
                      registration = EventRegistration.where(sadhak_profile_id: sadhak_profile_id, event_id: [india_event_id, global_event_id], status: EventRegistration.valid_registration_statuses).last

                      if registration.present?
                        message = 'Profile already registered.'
                      else

                        registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: detail[:event_seating_category_association_id], event_id: detail[:event_id], event_order_line_item_id: @event_order_line_item.id)

                        if registration.save
                          message = 'Profile registered successfully.'
                        else
                          errors.push([sadhak_profile_id, @event_order.reg_ref_number, member.id, registration.class.to_s, registration.errors.full_messages.to_sentence])
                          next
                        end

                      end

                      # Calculate expiry at
                      expiry_days = 365

                      joining_date = member.club_joining_date.try(:to_date)

                      unless joining_date.present?
                        joining_date = StripeSubscription.where(card: member.transaction_id, status: StripeSubscription.statuses['success']).last.try(:created_at).try(:to_date) || member.created_at.to_date
                        joining_date_missing_profiles.push([registration.id, member.id, member.sadhak_profile_id, member.sy_club_id, 'Joining date missing.'])
                      end

                      expiry_days -= (registration.created_at.try(:to_date) - joining_date).to_i

                      if expiry_days > registration.expires_at.to_i
                        registration.update_columns(expires_at: expiry_days)
                      end

                      # Update event registration id in member if no event registration association found
                      if registration.sy_club_member.present?
                        if registration.sy_club_member.id != member.id
                          member.update_columns(status: SyClubMember.statuses['expired'])
                        end
                      else
                        member.update_columns(event_registration_id: registration.id)
                      end

                      # push info to migrated
                      success.push([sadhak_profile_id, registration.id, member.id, registration.event_order.reg_ref_number, registration.event_id, member.sy_club_id, message])

                      puts "#{sadhak_profile_id}-#{registration.id}-#{member.id}-#{message}"

                    else
                      errors.push([sadhak_profile_id, @event_order.reg_ref_number, member.id, @event_order_line_item.class.to_s, @event_order_line_item.errors.full_messages.to_sentence])
                    end
                  end
                  if @event_order.event_registrations.count > 0
                    status = EventOrder.statuses['success']
                    is_deleted = false
                  else
                    status = EventOrder.statuses[@event_order.status]
                    is_deleted = true
                  end
                  @event_order.update_columns(sy_club_id: sy_club.id, status: status, is_deleted: is_deleted)
                  # raise ActiveRecord::Rollback if @event_order.event_registrations.count == 0
                end
              end
            end
          end
        end
      else
        puts 'No members registration found'
      end
      # Set last clp migration run
      # GlobalPreference.set_value_of('clp_migration_last_run', DateTime.now)
      # gp = GlobalPreference.unscoped.find_by_key('clp_migration_last_run')

      begin
        # Upload error and success file
        success_header = %w(SADHAK_PROFILE_ID REGISTRATION_ID FORUM_MEMBER_ID REG_REF_NUMBER EVENT_ID FORUM_ID MESSAGE)
        india_event.generate_excel_and_upload(rows: success, header: success_header, file_name: "india-event-#{india_event_id}-global-event-#{global_event_id}-clp-migration-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/clp_migration/india_global_clp_data_migration") if success.size > 0

        error_header = %w(SADHAK_PROFILE_ID REG_REF_NUMBER FORUM_MEMBER_ID MODEL ERRORS)
        india_event.generate_excel_and_upload(rows: errors, header: error_header, file_name: "india-event-#{india_event_id}-global-event-#{global_event_id}-clp-migration-#{DateTime.now.strftime('%F %T')}-failed.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/clp_migration/india_global_clp_data_migration") if errors.size > 0

        unmigrated_header = %w(MEMBER_ID FORUM_ID SADHAK_PROFILE_ID)
        india_event.generate_excel_and_upload(rows: unmigrated.collect{|m| [m.id, m.sy_club_id, m.sadhak_profile_id]}, header: unmigrated_header, file_name: "india-event-#{india_event_id}-global-event-#{global_event_id}-clp-migration-#{DateTime.now.strftime('%F %T')}-unmigrated.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/clp_migration/india_global_clp_data_migration") if unmigrated.size > 0

        joining_date_missing_profiles_header = %w(REGISTRATION_ID FORUM_MEMBER_ID SADHAK_PROFILE_ID FORUM_ID MESSAGE)
        india_event.generate_excel_and_upload(rows: joining_date_missing_profiles, header: joining_date_missing_profiles_header, file_name: "india-event-#{india_event_id}-global-event-#{global_event_id}-clp-migration-#{DateTime.now.strftime('%F %T')}-joining_date_missing_profiles.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/clp_migration/india_global_clp_data_migration") if joining_date_missing_profiles.size > 0
      rescue => e
        Rollbar.error(e)
      end

    rescue => e
      Rollbar.error(e)
    end
  end
end
