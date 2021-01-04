namespace :forum_data_migration do

  desc 'Migration of forum which was created ofline'
  # heroku run rake forum_data_migration:forum_basic_details_migration["offline_forum_data_migration/offline_forum_name_with_email.csv"]
  task :forum_basic_details_migration, [:filename] => :environment do |t, args|
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      forum_with_id = []
      errors = []
       ActiveRecord::Base.transaction do
        File.open(@file, 'r').each_with_index do |line, index|
          next unless line.strip.present?
          forum_name, contact_email =  line.strip.split("\t")

          forum_name = forum_name.try(:strip)
          contact_email = contact_email.try(:strip)

          sy_club = SyClub.new(name: forum_name.strip, email: contact_email)
          if sy_club.save
            forum_with_id.push([sy_club.name, sy_club.id])
            puts "Forum id: #{sy_club.id}, Name: #{sy_club.name} created successfully"
          else
            errors.push("Forum: #{forum_name} saving error: #{sy_club.errors.full_messages}")
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    if errors.present? and errors.count > 0
      puts errors
    else
      puts 'No error found'
      puts 'Forum with ids'
      puts forum_with_id
    end
  end

  desc 'Forum address update'
  # rake forum_data_migration:forum_address_migration["offline_forum_data_migration/offline_forum_with_address_details.csv"]
  task :forum_address_migration, [:filename] => :environment do |t, args|
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      errors = []
       ActiveRecord::Base.transaction do
        File.open(@file, 'r').each_with_index do |line, index|
          next unless line.strip.present?

          other_state = nil
          other_city = nil

          forum_name, state_name, city_name, country_name, street_address =  line.strip.split("\t")
          forum_name = forum_name.try(:strip)
          state_name = state_name.try(:strip)
          city_name = city_name.try(:strip)
          country_name = country_name.try(:strip)
          street_address = street_address.try(:strip)

          DbCountry.find_by(name: country_name)
          db_state = DbState.find_by(name: state_name)
          db_city = db_state.cities.where(name: city_name).last if db_state.present?

          country_id = 113
          city_id = db_city.try(:id)
          state_id = db_state.try(:id)

          forum = SyClub.find_by(name: forum_name)

          unless city_id.present?
            city_id = 999999
            other_city = city_name
          end

          unless state_id.present?
            state_id = 99999
            other_state = state_name
          end

          if forum.present?
            club_address = Address.new(addressable_id: forum.id, addressable_type: 'SyClub', city_id: city_id, state_id: state_id, country_id: country_id, first_line: street_address, other_state: other_state, other_city: other_city)
            if club_address.save
              puts "Forum id: #{forum.id} - Address created successfully"
            else
              binding.pry if ENV['ENVIRONMENT'] == 'development'
              errors.push("Error in saving id: #{forum.id} - #{club_address.errors.full_messages}")
            end
          else
            binding.pry if ENV['ENVIRONMENT'] == 'development'
            puts "Forum name: #{forum_name}, present: #{forum.present?}"
            raise ActiveRecord::Rollback
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    if errors.present? and errors.count > 0
      puts errors
    else
      puts 'No error found'
    end
  end

  desc 'Migration for offline forum members list'
  # rake forum_data_migration:forum_members_migration["offline_forum_data_migration/02-05-2017/Cash_Regs_Member_to_be_Updated_on_Portal_2_May_2017.xlsx","Email Ref: Offline Forums Data to be Updated on portal. Dated: May 01 2017. Sandeep Ji requested to mark these registration as cash for accounting purpose."]
  task :forum_members_migration, [:filename, :additional_details, :recipients] => :environment do |t, args|
    include CommonHelper
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      # @file = File.open(args[:filename], "r")

      result = []
      result_header = %w(SADHAK_PROFILE_ID CLUB_NAME CLUB_MEMBER_ID CLUB_REGISTRATION_ID MESSAGE)
      details = Hash.new
      file_name = 'offline-forum-members-migration'
      additional_details = args[:additional_details].to_s

      recipients = args[:recipients].present? ? args[:recipients].to_s.split('-') : %w(prince@metadesignsolutions.in)

      india_event_id = GlobalPreference.get_value_of('india_clp_events').to_s.split(',').first
      global_event_id = GlobalPreference.get_value_of('global_clp_events').to_s.split(',').first

      # We are moving data to clp product so it will automatic consider 1st seating category for data movement.
      india_event = Event.find(india_event_id)
      global_event = Event.find(global_event_id)

      event_seating_category_association = india_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details[:india] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event_id, global_event_id]}

      event_seating_category_association = global_event.event_seating_category_associations.first
      seating_category_id = event_seating_category_association.seating_category_id #18
      event_seating_category_association_id = event_seating_category_association.id #98
      price = event_seating_category_association.price #50

      details[:global] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event.id, global_event.id]}

      excel_data = SyClub.read_xlsx(@file)

      SYID = "syid"
      FORUM_ID = "forum_id"
      REGISTRATION_DATE = "registration_date"

      raise "SYID column is missing in excel sheet." unless excel_data[:header].include?(SYID)
      raise "Forum ID column is missing in excel sheet." unless excel_data[:header].include?(FORUM_ID)
      raise "Registration Date column is missing in excel sheet." unless excel_data[:header].include?(REGISTRATION_DATE)

      errors = []
      error_header = []
      fresh = []
      renewals = []
      updates = []
      processed_sadhak_ids = []

      excel_data[:content].each do |r|

        begin

          r = r.with_indifferent_access

          syid = r[SYID].to_s[/-?\d+/].to_i

          sadhak_profile = SadhakProfile.find(syid)

          forum = SyClub.find(r[:forum_id])

          join_date = r[REGISTRATION_DATE].kind_of?(Date) ? r[REGISTRATION_DATE] : Date.parse(r[REGISTRATION_DATE])

          raise "SYID: #{sadhak_profile.syid} has invalid joining date" unless join_date.present?

          raise "Forum Address not present for #{forum.name}" unless forum.address.try(:country_id).present?

          detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

          registrations = EventRegistration.where(sadhak_profile_id: syid, event_id: detail[:searchable_ids], status: EventRegistration.valid_registration_statuses)

          raise "Multiple registrations found for sadhak profile id: #{syid} on CLP." if registrations.count > 1

          registration = registrations.last

          member = registration.try(:sy_club_member)

          if (sadhak_profile.renewal_events.collect(&:id).map(&:to_s) & detail[:searchable_ids]).size.nonzero?

            raise "Not allowed to renew sadhak id #{syid} on forum: #{forum.name}-#{forum.id} because syid is registered on #{member.sy_club.name}-#{member.sy_club_id}." unless registration.event_id == detail[:event_id]

            renewals << r.merge(syid: syid)

          elsif registration.present?

            updates << r.merge(syid: syid)

          else

            fresh << r.merge(syid: syid)

          end

          processed_sadhak_ids << syid

        rescue => exception

          errors << (r.values + [exception.message])

          error_header = (r.keys.map(&:upcase) + ['ERROR']) if error_header.size.zero?

        end

      end

      raise "Duplicate sadhak profile found." if processed_sadhak_ids.size != processed_sadhak_ids.uniq.size

      [fresh, renewals].each do |fresh_renewals|

        # Process Fresh Registrations
        fresh_renewals.group_by(&:forum_id).each do |forum_id, sadhaks|

          next if sadhaks.size.zero?

          forum = SyClub.find(forum_id)

          detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

          sadhaks.each_slice(10) do |_sadhaks|

            begin

              _success = []

              ActiveRecord::Base.transaction do

                event_order = EventOrder.new(event_id: detail[:event_id], guest_email: 'syitemails@gmail.com', is_guest_user: true, sy_club_id: forum.id)

                _sadhaks.each do |to_be_reg_member|

                  event_order.event_order_line_items.build(sadhak_profile_id: to_be_reg_member[SYID], seating_category_id: detail[:seating_category_id], event_seating_category_association_id: detail[:event_seating_category_association_id], price: detail[:price])

                end
                event_order.save!
                EventRegistration.without_callbacks(:notify_registration) do

                  cash_payment = PgCashPaymentTransaction.new(payment_date: Time.zone.now.to_date, is_terms_accepted: true, additional_details: additional_details, event_order_id: event_order.id)

                  cash_payment.save!

                  event_order.update!(sy_club_id: forum.id, status: EventOrder.statuses['success'], payment_method: 'Cash Payment', transaction_id: cash_payment.transaction_number)

                  event_order = event_order.reload

                  raise "Unable to create registrations." unless event_order.valid_event_registrations.exists?

                  event_order.valid_event_registrations.each do |registration|

                    r = _sadhaks.find{|s| s[:syid].to_i == registration.sadhak_profile_id }
                    # Message
                    message = 'Member created successfully.'

                    join_date = r[REGISTRATION_DATE].kind_of?(Date) ? r[REGISTRATION_DATE] : Date.parse(r[REGISTRATION_DATE])

                    member = registration.try(:sy_club_member)

                    # Calculate expiry at
                    expiry_days = 365

                    expiry_days -= (registration.created_at.try(:to_date) - join_date).to_i


                    old_expiry_days = registration.expires_at.to_i

                    if expiry_days > old_expiry_days
                      registration.update_columns(expires_at: expiry_days)
                    end

                    puts "SYID: #{member.sadhak_profile_id}, Registration ID: #{registration.id}, Member ID: #{member.id}"

                    _success.push([member.sadhak_profile_id, forum.name, member.id, registration.id, message])

                  end

                  cash_payment.update_columns(sy_club_id: forum.id, status: PgCashPaymentTransaction.statuses.approved, amount: detail[:price] * event_order.valid_event_registrations.count)

                end

                result += _success

              end

            rescue => exception

              _sadhaks.each do |s|

                errors << (s.values + [exception.message])

              end

            end

          end

        end

      end

      # Update existing registrations
      updates.group_by(&:forum_id).each do |forum_id, sadhaks|

        next if sadhaks.size.zero?

        forum = SyClub.find(forum_id)

        detail = forum.address.try(:country_id) == 113 ? details[:india] : details[:global]

        sadhaks.each_slice(10) do |_sadhaks|

          begin

            _success = []

            ActiveRecord::Base.transaction do

              _sadhaks.each do |to_be_reg_member|

                join_date = to_be_reg_member[REGISTRATION_DATE].kind_of?(Date) ? to_be_reg_member[REGISTRATION_DATE] : Date.parse(to_be_reg_member[REGISTRATION_DATE])

                is_expiry_days_updated = false

                registration = EventRegistration.where(sadhak_profile_id: to_be_reg_member[SYID], event_id: detail[:searchable_ids], status: EventRegistration.valid_registration_statuses).last

                member = registration.try(:sy_club_member)

                # Calculate expiry at
                expiry_days = 365

                expiry_days -= (registration.created_at.try(:to_date) - join_date).to_i

                old_expiry_days = registration.expires_at.to_i

                if expiry_days > old_expiry_days
                  is_expiry_days_updated = registration.update_columns(expires_at: expiry_days)
                end

                puts "SYID: #{member.sadhak_profile_id}, Registration ID: #{registration.id}, Member ID: #{member.id}, Is Expiry Days Updated: #{is_expiry_days_updated}"

                _success.push([member.sadhak_profile_id, forum.name, member.id, registration.id, "Is expiry days updated: #{is_expiry_days_updated} - Old expiry days: #{old_expiry_days} - Updated expiry days: #{expiry_days}"])

              end

              result += _success

            end

          rescue => exception

            _sadhaks.each do |s|

              errors << (s.values + [exception.message])

            end

          end

        end

      end

    rescue => e
      ApplicationMailer.send_email(recipients: recipients, subject: "Error: Offline Forum Data Migration Result: File - #{file_name} Error Message- #{e.message}").deliver
    end

    begin
      SyClub.last.generate_excel_and_upload(rows: errors, header: error_header, file_name: "#{file_name}-#{DateTime.now.strftime('%F %T')}-error.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/forum_data_migration/forum_members_migration") if errors.size.nonzero?
    rescue Exception => e
      puts "Error while uploading error file, error: #{e.message}."
    end

    begin
      SyClub.last.generate_excel_and_upload(rows: result, header: result_header, file_name: "#{file_name}-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/forum_data_migration/forum_members_migration") if result.size.nonzero?
    rescue Exception => e
      puts "Error while uploading success file, error: #{e.message}."
    end

    if recipients.present?
      begin
        attachments = {}

        attachments["#{file_name}-#{DateTime.now.strftime('%F %T')}-error.xls"] = GenerateExcel.generate(rows: errors, header: error_header) if errors.size.nonzero?

        attachments["#{file_name}-#{DateTime.now.strftime('%F %T')}-success.xls"] = GenerateExcel.generate(rows: result, header: result_header) if result.size.nonzero?

        ApplicationMailer.send_email(recipients: recipients, subject: "Offline Forum Data Migration Result: File - #{file_name}", attachments: attachments).deliver

      rescue => exception
        puts "Error while sending email."
      end
    end

    puts 'Process Completed.'
  end

   desc 'Migration for ofline forum organizers list'
   # rake forum_data_migration:forum_organizers_migration["offline_forum_data_migration/offline_forum_organizers.csv"]
  task :forum_organizers_migration, [:filename] => :environment do |t, args|
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      errors = []
       ActiveRecord::Base.transaction do
          File.open(@file, 'r').each_with_index do |line, index|
          next unless line.strip.present?
           syid, role_id, forum_name =  line.strip.split("\t")
          syid = syid.try(:strip)
          role_id = role_id.try(:strip)
          forum_name = forum_name.try(:strip)
           forum = SyClub.find_by(name: forum_name.strip)
          if forum.present?
            forum_sp_associtaion = SyClubSadhakProfileAssociation.where(sy_club_id: forum.id, sadhak_profile_id: syid, sy_club_user_role_id: role_id).last
            if forum_sp_associtaion.present?
              binding.pry if ENV['ENVIRONMENT'] == 'development'
              puts "Syid : #{syid} alredady board member of forum : #{forum.id} - index: #{index+1}"
            else
              forum_associtaion = SyClubSadhakProfileAssociation.new(sy_club_id: forum.id, sadhak_profile_id: syid, sy_club_user_role_id: role_id)
              if forum_associtaion.save
                puts "Syid #{syid}, role_id: #{role_id} associated to forum: #{forum.id} - index: #{index+1}"
              else
                binding.pry if ENV['ENVIRONMENT'] == 'development'
                errors.push("Error in saving: SYID: #{syid} - forum id: #{forum.id} - errors: #{forum_associtaion.errors.full_messages} - index: #{index+1}")
              end
            end
          else
            binding.pry if ENV['ENVIRONMENT'] == 'development'
            puts "Forum doesnt found with name: #{forum_name} - index: #{index+1}"
            raise ActiveRecord::Rollback
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    if errors.present? and errors.count > 0
      puts errors
    else
      puts 'No error found'
    end
  end

  # rake forum_data_migration:forum_specific_members_data_migration["offline_forum_data_migration/forum_specific_members_data_524.csv"]
  #rake forum_data_migration:forum_specific_members_data_migration["offline_forum_data_migration/forum_specific_members_data_591.csv"]
  task :forum_specific_members_data_migration, [:filename] => :environment do |t, args|
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename])
      errors = []
      forum_id = 591
       ActiveRecord::Base.transaction do
          File.open(@file, 'r').each_with_index do |line, index|
          next unless line.strip.present?
           syid, first_name, last_name,  transaction_id=  line.strip.split("\t")
          member = SyClubMember.where(sy_club_id: forum_id, sadhak_profile_id: syid, status: 1).last
          if member.present?
            puts "Member already exist #{syid} with id: #{member.id}."
          else
            member = SyClubMember.where(sy_club_id: forum_id, sadhak_profile_id: syid).last

            # below line commented for forum 591 migration
            # transaction_id =  'offline' + '524-' + SecureRandom.base64(8).to_s

            if member.present?
              errors.push("Error in updating: #{member.id}: errors: #{member.errors}") unless member.update_columns(transaction_id: transaction_id, status: 1)
            else
              member = SyClubMember.new(sy_club_id: forum_id, sadhak_profile_id: syid, status: 1, transaction_id: transaction_id)
              if member.save
                puts "Member created successfully - #{index}"
              else
                errors.push("Error in saving: #{syid} - errors: #{member.errors}")
              end
            end
          end
        end
      end
    rescue Exception => e
      puts e.backtrace
    end
    if errors.present? and errors.count > 0
      puts errors
    else
      puts 'No error found'
    end
  end

  # Task to move members from one forum to another (Remove dupicate forums)
  # rake forum_data_migration:dupilcate_forums_migration[]
  task :dupilcate_forums_migration, [:filename, :from, :to] => :environment do |t, args|
    begin
      Rake::Task['import_sadhak_profile_03052015:read_file_from_s3'].invoke(args[:filename]) if args[:filename].present?
      errors = []
      ActiveRecord::Base.transaction do
        # Process file if file present or process single forum if from and to present
        if args[:filename].present?
          puts 'Processing file.'
          File.open(@file, 'r').each_with_index do |line, index|
            next unless line.strip.present?
            from, to =  line.strip.split("\t")
            do_migrate_forum_members(from, to)
            puts "Processed index : #{index + 1}."
          end
        elsif args[:from].present? and args[:to].present?
          puts 'Processing individual forum'
          do_migrate_forum_members(args[:from], args[:to])
        else
          raise ArgumentError, 'Please input parameters in task.'
        end
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
    end
    puts 'Process Completed.'
  end

  # Method that will migrate data from one forum to another
  def do_migrate_forum_members(from, to)
    result = []
    raise ArgumentError, 'Arguments missing' if from.nil? or to.nil?
    from_club = SyClub.find(from)
    to_club = SyClub.find(to)

    raise 'Atleast one forum address must be present.' if to_club.address.try(:country_id).nil? and from_club.address.try(:country_id).nil?

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
    details[:india] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event_id, global_event_id]}

    event_seating_category_association = global_event.event_seating_category_associations.first
    seating_category_id = event_seating_category_association.seating_category_id #18
    event_seating_category_association_id = event_seating_category_association.id #98
    price = event_seating_category_association.price #50

    details[:global] = {seating_category_id: seating_category_id, event_seating_category_association_id: event_seating_category_association_id, price: price, event_id: event_seating_category_association.event_id, searchable_ids: [india_event_id, global_event_id]}

    if to_club.address.try(:country_id) == 113 or from_club.address.try(:country_id) == 113
      detail = details[:india]
    else
      detail = details[:global]
    end

    puts "Migrating members from: #{from_club.name}-#{from_club.id} to: #{to_club.name}-#{to_club.id}."
    file_name = "members-migration-result-from-#{from_club.id}-to-#{to_club.id}"

    to_club_members = to_club.sy_club_members

    # Real logic of migration
    from_club.sy_club_members.each do |_from_member|

      # Check the status if approved member then proceed else soft delete with metadata
      if SyClubMember.statuses[_from_member.status] == SyClubMember.statuses['approve']
        registration = create_or_find_clp_registration(detail, _from_member)

        _from_member = _from_member.reload

        if registration.id != _from_member.event_registration_id

          result.push([_from_member.sadhak_profile_id, _from_member.sy_club_id, _from_member.id, _from_member.event_registration_id, "Found Registered on forum: #{registration.sy_club_member.sy_club_id}", "Found Member ID: #{registration.sy_club_member.id}", "Found Registration ID: #{registration.id}", "Sadhak profile registered on other forum (#{registration.sy_club_member.sy_club_id}), clp registration id: #{registration.id}, member id: #{registration.sy_club_member.id}"])

          _from_member.update_columns(is_deleted: true, metadata: "Marked deleted and migrated from #{from_club.id} to #{to_club.id} forum. Time: #{Time.now}")

          next
        end

        # Update event order sy_club_id as it is associated with same forum or created a new one against same
        registration.event_order.update_columns(sy_club_id: to_club.id)

        # Find in exisiting members in which we are moving
        found = to_club_members.find{ |_m| _m.sadhak_profile_id == _from_member.sadhak_profile_id }

        # Raise error if _from_member_id match with registration_associated_member_id and we found one more approved entry in to_club members
        raise "Double forum members entry found: first_member_id: #{_from_member.id}, second_member_id: #{found.id}" if found.present? and SyClubMember.statuses[found.status] == SyClubMember.statuses['approve'] and found.event_registration.present?

        # Found: Proceed else create a fresh entry from old member
        if found.present? and SyClubMember.statuses.slice(:pending, :approve).values.include?(SyClubMember.statuses[found.status])

          status_was = found.status

          found.update_columns(_from_member.attributes.deep_symbolize_keys.except(:id, :created_at, :updated_at, :sy_club_id).merge({status: SyClubMember.statuses['approve']}))

          result.push([found.sadhak_profile_id, _from_member.sy_club_id, _from_member.id, _from_member.event_registration_id, found.sy_club_id, found.id, found.event_registration_id, "Member found with #{status_was} status."])

          _from_member.update_columns(is_deleted: true, metadata: "Marked deleted and migrated from #{from_club.id} to #{to_club.id} forum. Found a member with id: #{found.id} and status was #{status_was}. Time: #{Time.now}")

        else

          # Create a new entry to this club and no need to assign validity days and registration id as it is copied
          new_member = SyClubMember.new(_from_member.attributes.deep_symbolize_keys.except(:id, :created_at, :updated_at).merge({sy_club_id: "#{to_club.id}", status: SyClubMember.statuses['approve']}))

          raise ActiveRecord::Rollback, new_member.errors.full_messages.first unless new_member.save

          result.push([new_member.sadhak_profile_id, _from_member.sy_club_id, _from_member.id, _from_member.event_registration_id, new_member.sy_club_id, new_member.id, new_member.event_registration_id, 'New member created successfully.'])

          _from_member.update_columns(is_deleted: true, metadata: "Marked deleted while migrating members from #{from_club.id} to #{to_club.id} forum. Created a new entry with id: #{new_member.id}. Time: #{Time.now}")

        end
      else

        _from_member.update_columns(is_deleted: true, metadata: "Marked deleted because status was #{_from_member.status} while migrating members from #{from_club.id} to #{to_club.id} forum. Time: #{Time.now}")
      end
    end

    # Mark forum as deleted
    from_club.update_columns(is_deleted: true, metadata: "Members are migrated to forum #{to_club.id}. Email Reference: Fwd: Duplicate Forums' Data to be Removed. Time: #{Time.now}")

    begin
      result_header = %w(SADHAK_PROFILE_ID FROM_CLUB FROM_CLUB_MEMBER_ID FROM_CLUB_REGISTRATION_ID TO_CLUB TO_CLUB_MEMBER_ID TO_CLUB_REGISTRATION_ID MESSAGE)
      from_club.generate_excel_and_upload(rows: result, header: result_header, file_name: "#{file_name}-#{DateTime.now.strftime('%F %T')}-success.xls", prefix: "#{ENV['ENVIRONMENT']}/scripts/forum_data_migration/dupilcate_forums_migration") if result.size > 0
    rescue => e
      Rollbar.error(e)
    end
  end

  def create_or_find_clp_registration(detail, member)
    is_expiry_days_updated = false

    registrations = EventRegistration.where(sadhak_profile_id: member.sadhak_profile_id, event_id: detail[:searchable_ids], status: EventRegistration.valid_registration_statuses)

    raise "Multiple registrations found for sadhak profile id: #{member.sadhak_profile_id} on CLP." if registrations.size > 1

    registration = registrations.last

    unless registration.present?
      @event_order = EventOrder.new(event_id: detail[:event_id], guest_email: member.guest_email, is_guest_user: true, payment_method: member.payment_method, transaction_id: member.transaction_id)

      if @event_order.save

        sadhak_profile_id = member.sadhak_profile_id

        @event_order_line_item = EventOrderLineItem.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, seating_category_id: detail[:seating_category_id], event_seating_category_association_id: detail[:event_seating_category_association_id], price: detail[:price])

        if @event_order_line_item.save

          registration = EventRegistration.new(event_order_id: @event_order.id, sadhak_profile_id: sadhak_profile_id, event_seating_category_association_id: detail[:event_seating_category_association_id], event_id: detail[:event_id], event_order_line_item_id: @event_order_line_item.id)

          raise registration.errors.full_messages.first unless registration.save

        else
          raise @event_order.errors.full_messages.first
        end
        if @event_order.event_registrations.count > 0
          status = EventOrder.statuses['success']
          is_deleted = false
        else
          status = EventOrder.statuses[@event_order.status]
          is_deleted = true
        end
        @event_order.update_columns(sy_club_id: member.sy_club_id, status: status, is_deleted: is_deleted)
      end
    end

    # Calculate expiry at
    expiry_days = 365

    joining_date = member.club_joining_date.try(:to_date)

    unless joining_date.present?
      joining_date = StripeSubscription.where(card: member.transaction_id, status: StripeSubscription.statuses['success']).last.try(:created_at).try(:to_date) || member.created_at.to_date
    end

    expiry_days -= (registration.created_at.try(:to_date) - joining_date).to_i

    old_expiry_days = registration.expires_at.to_i

    if expiry_days > old_expiry_days
      is_expiry_days_updated = registration.update_columns(expires_at: expiry_days)
    end

    # Update event registration id in member if no event registration association found
    if registration.sy_club_member.present?
      if registration.sy_club_member.id != member.id
        member.update_columns(status: SyClubMember.statuses['expired'])
      end
    else
      member.update_columns(event_registration_id: registration.id)
    end

    puts "SYID: #{member.sadhak_profile_id}, Registration ID: #{registration.id}, Member ID: #{member.id}, Is Expiry Days Updated: #{is_expiry_days_updated}"

    return registration
  end



  desc 'Migration for Forum Board Members'

  task :forum_boad_member_migration,[:recipients] => :environment do |t, args|

    include CommonHelper
    header = %w(FORUM_ID FORUM_NAME CITY STATE COUNTRY OLD_PRESIDENT OLD_PRESIDENT_CONTACT_INFO OLD_VPRESIDENT OLD_VPRESIDENT_CONTACT_INFO  OLD_SECETORY OLD_SECETORY_CONTACT_INFO NEW_PRESIDENT NEW_VPRESIDENT ERROR)
    rows = []


    sylub_ids = SyClub.enabled.joins(:sy_club_sadhak_profile_associations, :address).where("addresses.country_id IS NOT NULL AND sy_club_sadhak_profile_associations.sy_club_user_role_id = 1 AND sy_club_sadhak_profile_associations.created_at::date <= now()::date - 365").ids

    puts "#{sylub_ids.size} will be execute."
    SyClub.where(id: sylub_ids).includes({sy_club_sadhak_profile_associations: [:sadhak_profile]}, :address).each do |sy_club|
      puts "forum #{sy_club.id} / #{sy_club.name} is being excuted."
        row = []
        error = ""

        next if sy_club.sy_club_sadhak_profile_associations.count != 3
        row.push(sy_club.id)
        row.push(sy_club.name)
        sy_club.try(:address).tap do |address|
          row.push(address.city_name)
          row.push(address.state_name)
          row.push(address.country_name)
        end

        # Create new Object in Advisory Counsil Table(president details)
        # Remove president
        # Create new Association for p(upgrade vp)
        # Remove vp
        # Create new Association for secetory
        # Remove secetory

        president = sy_club.sy_club_sadhak_profile_associations.find{|aso| aso.sy_club_user_role_id == 1}
        vpresident = sy_club.sy_club_sadhak_profile_associations.find{|aso| aso.sy_club_user_role_id == 2}
        secetory = sy_club.sy_club_sadhak_profile_associations.find{|aso| aso.sy_club_user_role_id == 3}

        begin
          ActiveRecord::Base.transaction do
            advisory_counsil = AdvisoryCounsil.new(sadhak_profile_id: president.sadhak_profile_id, sy_club_id: sy_club.id, club_joining_date: president.club_joining_date, guest_email: president.guest_email)
            if president.destroy && advisory_counsil.save
              row.push("SY#{advisory_counsil.sadhak_profile_id}")
              puts "New advisory_counsil SY#{advisory_counsil.sadhak_profile_id} has been created successfully. OLD President SY#{president.sadhak_profile_id} has been removed."
            else
              row.push(" ")
              puts "Error: #{advisory_counsil.errors.full_messages || president.errors.full_messages}"
              raise Exception, advisory_counsil.errors.full_messages || president.errors.full_messages
            end

            new_president = sy_club.sy_club_sadhak_profile_associations.new(sadhak_profile_id: vpresident.sadhak_profile_id, club_joining_date: vpresident.club_joining_date, sy_club_user_role_id: 1, guest_email: vpresident.guest_email, status: 1)
            if vpresident.destroy && new_president.save
              row.push("SY#{new_president.sadhak_profile_id}")
              puts "New President SY#{new_president} has been created successfully.OLD Vice President SY#{vpresident.sadhak_profile_id} has been removed."
            else
              row.push(" ")
              puts "Error: #{new_president.errors.full_messages || vpresident.errors.full_messages}"
              raise Exception, new_president.errors.full_messages || vpresident.errors.full_messages
            end

            new_vpresident = sy_club.sy_club_sadhak_profile_associations.new(sadhak_profile_id: secetory.sadhak_profile_id, club_joining_date: secetory.club_joining_date, sy_club_user_role_id: 2, guest_email: secetory.guest_email, status: 1)
            if secetory.destroy && new_vpresident.save
              row.push("SY#{new_vpresident.sadhak_profile_id}")
              puts "New Vice president SY#{new_president} been created successfully.OLD Secetory SY#{secetory.sadhak_profile_id} has been removed."
            else
              row.push(" ")
              puts "Error: #{new_vpresident.errors.full_messages || secetory.errors.full_messages}"
              raise Exception, new_vpresident.errors.full_messages || secetory.errors.full_messages
            end
          end
        rescue Exception => e
         row.push(e.message)
        end
        rows.push(row)

    end
    puts "Execution has been finished."
    recipients = (args[:recipients].present? && args[:recipients].split(',').extract_valid_emails) || []
    recipients += ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'development'
    recipients += ENV['TESTING_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'testing'
    attachments = {}
    puts "Sending mails Report Data"
    attachments["board member migration report data#{Time.now.strftime("%d-%m-%y-%l_%M_%S")
}.xls"] =  GenerateExcel.generate(rows: rows, header: header)
    ApplicationMailer.send_email(recipients: recipients, subject: "Board member migration report data - #{Date.today}", attachments: attachments).deliver
      end
end
