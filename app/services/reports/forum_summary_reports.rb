class Reports::ForumSummaryReports
  class << self

    def global_summary
      info = {
        file_name: 'global_forum_summary',
        key: 'global_forum_summary_emails',
        subject: 'Global Forum Summary Report',
        identifier: 'global',
        from: 'support@absclp.com'
      }
      sy_clubs = SyClub.active_global
      generate_summary_report(sy_clubs, info)
      generate_consolidated_members_report(sy_clubs, nil, info)
    end

    def india_summary
      info = {
        file_name: 'india_forum_summary',
        key: 'india_forum_summary_emails',
        subject: 'India Forum Summary Report',
        identifier: 'india',
        from: 'registration@shivyogindia.com'
      }
      sy_clubs = SyClub.active_india
      generate_summary_report(sy_clubs, info)
      generate_consolidated_members_report(sy_clubs, nil, info)
    end

    def generate_summary_report(sy_clubs, info)
      club_roles = SyClubUserRole.all.collect{|r| {id: r.id, role_name: r.role_name}}.each {|r| r[:role_name].upcase!}
      columns_for_member_list = %w(SYID FULLNAME MOBILE EMAIL PHOTO_ID_UPLOADED PHOTO_ID_APPROVED PHOTO_ID_PROOF_UPLOADED PHOTO_ID_PROOF_APPROVED PHOTO_ID_PROOF_NUMBER ADDRESS_PROOF_UPLOADED ADDRESS_PROOF_APPROVED PHOTO_ID_LAST_UPDATED PHOTO_ID_PROOF_LAST_UPDATED)
      columns_for_forum_list = %w(FORUM_ID COUNTRY STATE CITY ADDRESS FORUM_NAME MEMBERS_COUNT CREATED_AT UPDATED_AT')
      club_roles.each do |m_role|
        columns_for_member_list.each do |m_detail_column|
          columns_for_forum_list.push(m_role[:role_name] + '_' + m_detail_column)
        end
        columns_for_forum_list.push("IS_#{m_role[:role_name]}_FORUM_MEMBER?")
        columns_for_forum_list.push("#{m_role[:role_name]}_PAYMENT_DATE")
        columns_for_forum_list.push("#{m_role[:role_name]}_EXPIRATION_DATE")
        columns_for_forum_list.push("IS_#{m_role[:role_name]}_RENEWED?")
        columns_for_forum_list.push("#{m_role[:role_name]}_MEMBERSHIP_STATUS")
      end

      forum_list = []

      sy_clubs.includes(:address).find_in_batches(batch_size: 200).with_index do |batch, index|

        batch.each do |club|

          club_address = club.address
          member_sadhak_ids = club.approved_members.pluck(:id)
          members_count = member_sadhak_ids.size

          club_admins = club.sy_club_sadhak_profile_associations.select{|a| a.sy_club_user_role_id != nil}
                            .collect{|s|
                              {
                                  sadhak_profile_id: s.sadhak_profile_id,
                                  fullname: s.try(:sadhak_profile).try(:full_name).try(:titleize),
                                  sy_club_user_role_id: s.sy_club_user_role_id,
                                  syid: s.try(:sadhak_profile).syid,
                                  email: s.try(:sadhak_profile).try(:email),
                                  mobile: s.try(:sadhak_profile).try(:mobile),
                                  photo_id_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No',
                                  photo_id_approved: s.try(:sadhak_profile).try(:profile_photo_status) == 'pp_success' ? 'Yes' : 'No',
                                  photo_id_proof_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_identity_proof).present? ? 'Yes' : 'No',
                                  photo_id_proof_approved: s.try(:sadhak_profile).try(:photo_id_status) == 'pi_success' ? 'Yes' : 'No',
                                  photo_id_proof_number: s.try(:sadhak_profile).try(:advance_profile).try(:photo_id_proof_number).to_s,
                                  address_proof_uploaded: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_address_proof).present? ? 'Yes' : 'No',
                                  address_proof_approved: s.try(:sadhak_profile).try(:address_proof_status) == 'ap_success' ? 'Yes' : 'No',
                                  photo_id_last_updated: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_photograph).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p'),
                                  photo_id_proof_last_updated: s.try(:sadhak_profile).try(:advance_profile).try(:advance_profile_identity_proof).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
                              }
                            }

          hash = Array.new
          hash.push(club.id)
          hash.push(club_address.try(:country_name))
          hash.push(club_address.try(:state_name))
          hash.push(club_address.try(:city_name))
          hash.push(club_address.try(:full_address))

          hash.push(club.name.try(:titleize))
          hash.push(members_count)
          hash.push(club.created_at.strftime('%F %T'))
          hash.push(club.updated_at.strftime('%F %T'))

          # Push board members details
          club_roles.each do |club_role|
            role = (club_admins.find{|c| c[:sy_club_user_role_id] == club_role[:id]} || {})
            columns_for_member_list.each do |m_detail_column|
              hash.push(role.present? ? role[m_detail_column.downcase.to_sym] : 'NA')
            end

            # Is active member of current forum
            hash.push(role.present? ? member_sadhak_ids.include?(role[:sadhak_profile_id]) : 'NA')

            # Find active membership record
            member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:approve).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).last

            # If active membership not found then search in expired members
            unless member.present?
              member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:expired).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).last
            end

            # Find associated registration
            registration = member.try(:event_registration)

            # Compute Payment Date
            payment_date = nil
            if member.present?
              loop do
                gateway = (TransferredEventOrder.gateways.find{|g| g[:payment_method] == member.payment_method} || {})
                payment_date = gateway[:model].try(:constantize).try(:where, {gateway[:transaction_id] => member.transaction_id, status: gateway[:success]}).try(:last).try(:created_at)
                if payment_date.nil?
                  if member.metadata.to_s.include?('Transferred_from_member_id')
                    member = SyClubMember.unscoped.find_by_id(member.metadata.to_s[/-?\d+/].to_i)
                  else
                    payment_date = (member.club_joining_date || member.created_at)
                    member = nil
                  end
                end
                break if (payment_date.present? || member.nil?)
              end
            end
            hash.push(payment_date.present? ? payment_date.try(:strftime, ('%b %d, %Y')) : 'NA')

            # Push expiration date
            hash.push(registration.present? ? "#{(registration.created_at.to_date + registration.expires_at - 1).strftime('%b %d, %Y')}" : 'NA')

            # Is renewed
            renewed_member = SyClubMember.where('event_registration_id IS NOT ? AND status IN (?) AND sy_club_id = ? AND sadhak_profile_id = ?', nil, SyClubMember.statuses.slice(:renewed).values, club.id, role[:sadhak_profile_id]).includes(:event_registration).order('created_at DESC').first
            is_renewed = (renewed_member.present? and renewed_member.event_registration == registration.try(:parent_registration))
            hash.push(is_renewed)

            if member.present?
              if member.approve?
                membership_status = 'Approve'
              elsif member.expired?
                membership_status = 'Expired'
              end
            else
              membership_status = 'NA'
            end

            hash.push(membership_status)

          end
          forum_list.push(hash)
        end

      end

      if forum_list.any?
        data = GenerateExcel.generate(rows: forum_list, header: columns_for_forum_list)
        attachments = Hash["#{info[:file_name]}_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", data]
        recipients = GlobalPreference.unscoped.where(key: "#{info[:key]}").last.try(:val).to_s.split(',')
        recipients += ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'development'
        recipients += ENV['TESTING_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'testing'
        ApplicationMailer.send_email(from: info[:from], recipients: recipients, subject: "#{info[:subject]} - #{Time.now.strftime('%d%m%Y%H%M%S%N')}", template: 'forum_member_count_country_wise', attachments: attachments).deliver if recipients.present?
      end

    rescue StandardError => e
      Rollbar.error(e)
    end

    # Create india and global forums consolidated members report.
    def generate_consolidated_members_report(sy_clubs = [], sadhak_ids = nil, info = {})
        # If sy_club_ids recieved as argument then it will be comma seperated forum ids
        sadhak_profile_ids = sadhak_ids.try(:split, ',')

        # Assign all club ids if no ids provided
        unless sy_clubs.present?
          if info.present?
            if info[:identifier] == 'india'
              sy_clubs = SyClub.joins(:address).where(addresses: {country_id: 113}).order('id ASC')
            elsif info[:identifier] == 'global'
              sy_clubs = SyClub.joins(:address).where.not(addresses: {country_id: [113, nil]}).order('id ASC')
            else
              sy_clubs = SyClub.all
            end
          else
            sy_clubs = SyClub.all
          end
        end

        recipients = GlobalPreference.unscoped.where(key: "#{info[:key]}").last.try(:val).to_s.split(',')
        recipients += ENV['DEVELOPMENT_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'development'
        recipients += ENV['TESTING_RESP'].extract_valid_emails if ENV['ENVIRONMENT'] == 'testing'
        recipients = recipients.extract_valid_emails

        columns_for_member_list = %w(FORUM_ID FORUM_NAME SYID FULLNAME MOBILE EMAIL COUNTRY STATE CITY PHOTO_ID_UPLOADED PHOTO_ID_APPROVED PHOTO_ID_PROOF_UPLOADED PHOTO_ID_PROOF_APPROVED PHOTO_ID_PROOF_NUMBER ADDRESS_PROOF_UPLOADED ADDRESS_PROOF_APPROVED PHOTO_ID_LAST_UPDATED PHOTO_ID_PROOF_LAST_UPDATED PAYMENT_DATE PAYMENT_METHOD TRANSACTION_ID EXPIRATION_DATE STATUS IS_RENEWED TRANSFERRED_TO_FORUM#ID DATE_OF_TRANSFER MEMBERSHIP_THROUGH_TRANSFER TRANSFER_FROM_FORUM#ID ACTIVE_MEMBER_IN_CURRENT_FORUM FRESH_APPLICANT PAST_MEMBER_FOR_1_YEAR TOTAL_EPISODES_ATTENDED MEMBER_ID)

        excel_rows_limit = (6e6 / (columns_for_member_list.size * 16)).to_i

        if sadhak_profile_ids.present?
          all_members = SyClubMember.unscoped.where('sy_club_id IN (?) AND sadhak_profile_id IN (?) AND event_registration_id IS NOT ? AND status NOT IN (?)', sy_clubs.pluck(:id), sadhak_profile_ids, nil, SyClubMember.statuses.slice(:pending).values)
        else
          all_members = SyClubMember.unscoped.where('sy_club_id IN (?) AND event_registration_id IS NOT ? AND status NOT IN (?)', sy_clubs.pluck(:id), nil, SyClubMember.statuses.slice(:pending).values)
        end

        members_list = Array.new
        sheet_index = 0

        all_members.find_in_batches(batch_size: 5000).with_index do |group, index|

          grouped_by_sadhak_id_members = {}
          group.group_by(&:sadhak_profile_id).each{|r| grouped_by_sadhak_id_members[r[0]] = r[1]}

          group.group_by(&:sy_club_id).each do |sy_club_id, club_members|

            club = SyClub.unscoped.where(id: sy_club_id).last

            raise "Forum not found with id: #{sy_club_id}" unless club.present?

            club_members.sort_by(&:created_at).group_by(&:sadhak_profile_id).each do |sadhak_profile_id, members|

              members = members.sort_by(&:created_at)

              approved_member = members.find{|m| SyClubMember.statuses['approve'] == SyClubMember.statuses[m.status] }

              # transferred_members = members.select{|m| SyClubMember.statuses['transferred'] == SyClubMember.statuses[m.status] }

              # expired_members = []

              unless approved_member.present?
                # expired_members = members.select{|m| SyClubMember.statuses['expired'] == SyClubMember.statuses[m.status] }
              end

              next if approved_member.nil? #and transferred_members.size == 0 and expired_members.size == 0

              ([approved_member] - [nil]).sort_by(&:created_at).each do |member|

                sp = member.sadhak_profile
                reg = member.event_registration

                is_member_approved = SyClubMember.statuses['approve'] == SyClubMember.statuses[member.status]

                # Basic row
                row = [club.id, club.name, "SY#{sadhak_profile_id}", sp.try(:full_name), sp.try(:mobile), sp.try(:email), sp.try(:address).try(:country_name), sp.try(:address).try(:state_name), sp.try(:address).try(:city_name)]

                row << (sp.try(:advance_profile).try(:advance_profile_photograph).present? ? 'Yes' : 'No')
                row << (sp.try(:profile_photo_status) == 'pp_success' ? 'Yes' : 'No')
                row << (sp.try(:advance_profile).try(:advance_profile_identity_proof).present? ? 'Yes' : 'No')
                row << (sp.try(:photo_id_status) == 'pi_success' ? 'Yes' : 'No')
                row << sp.try(:advance_profile).try(:photo_id_proof_number).to_s
                row << (sp.try(:advance_profile).try(:advance_profile_address_proof).present? ? 'Yes' : 'No')
                row << (sp.try(:address_proof_status) == 'ap_success' ? 'Yes' : 'No')
                row << sp.try(:advance_profile).try(:advance_profile_photograph).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')
                row << sp.try(:advance_profile).try(:advance_profile_identity_proof).try(:updated_at).try(:strftime, '%b %d, %Y - %I:%M:%S %p')

                # Payment Date
                t_member = member
                payment_date = nil
                payment_method = nil
                txn_id = nil
                loop do
                  gateway = (TransferredEventOrder.gateways.find{|g| g[:payment_method] == t_member.payment_method} || {})
                  txn = gateway[:model].try(:constantize).try(:where, {gateway[:transaction_id] => t_member.transaction_id, status: gateway[:success]}).try(:last)
                  payment_date = txn.try(:created_at)
                  payment_method = gateway[:payment_method]
                  txn_id = txn.try(:send, gateway[:transaction_id])
                  if payment_date.nil?
                    if t_member.metadata.to_s.include?('Transferred_from_member_id')
                      t_member = SyClubMember.unscoped.find_by_id(t_member.metadata.to_s[/-?\d+/].to_i)
                    else
                      payment_date = (t_member.club_joining_date || t_member.created_at)
                      t_member = nil
                    end
                  end
                  break if (payment_date.present? || t_member.nil?)
                end
                row.push(payment_date.try(:strftime, ('%b %d, %Y')))

                # Payment Method
                row.push(payment_method)

                # TRANSACTION_ID
                row.push(txn_id || member.transaction_id)

                # Expiration date
                row.push(reg.present? ? (reg.created_at.to_date + reg.expires_at - 1).try(:strftime, ('%b %d, %Y')) : nil)

                # Status
                row.push(member.status.try(:humanize))

                # Is renewed
                is_renewed = (grouped_by_sadhak_id_members[sadhak_profile_id] || []).select{|m| dt = (m.club_joining_date || m.created_at).to_date; dt_range = ((Date.today - 1.year)...Date.today); SyClubMember.statuses.slice(:renewed).values.include?(SyClubMember.statuses[m.status]) and (dt_range.include?(dt) || dt_range.include?(dt + 1.year))}.size > 0
                row.push(is_renewed)

                # If transferred then transferred club name
                row.push(member.transferred_to_club_id.present? ? "#{member.transferred_club_name} ##{member.transferred_to_club_id}" : nil)

                # Date of transfer
                date_of_transfer = nil
                if member.transferred_to_club_id.present?
                  date_of_transfer = SyClubMember.unscoped.where.not(event_registration_id: nil).where(sadhak_profile_id: member.sadhak_profile_id, metadata: "Transferred_from_member_id: #{member.id}.").last.try(:created_at).try(:strftime, ('%b %d, %Y'))
                end
                row.push(date_of_transfer)

                # Is member transferred in to this forum
                is_transferred_in = member.metadata.to_s.include?('Transferred_from_member_id')
                row.push(is_transferred_in)

                # If transfer in case then push from which forum
                transferred_from_club_name = nil
                if is_transferred_in
                  transferred_from_club = SyClubMember.unscoped.find_by_id(member.metadata.to_s[/-?\d+/].to_i).try(:sy_club)
                  transferred_from_club_name = "#{transferred_from_club.try(:name)} ##{transferred_from_club.try(:id)}" if transferred_from_club.present?
                end
                row.push(transferred_from_club_name)

                # Is active member of current forum
                row.push(is_member_approved)

                # Is applying for first time to this forum
                new_member = ((grouped_by_sadhak_id_members[sadhak_profile_id] || []).select{|m| SyClubMember.statuses.slice(:expired, :renewed, :transferred).values.include?(SyClubMember.statuses[m.status])}.size == 0 and is_member_approved)
                row.push(new_member)

                # Is past member of any forum for 1 year
                past_member = (grouped_by_sadhak_id_members[sadhak_profile_id] || []).select{|m| dt = (m.club_joining_date || m.created_at).to_date; dt_range = ((Date.today - 1.year)...Date.today); SyClubMember.statuses.slice(:expired, :renewed).values.include?(SyClubMember.statuses[m.status]) and (dt_range.include?(dt) || dt_range.include?(dt + 1.year))}.size > 0
                row.push(past_member)

                # Total episodes attended by Sadhak so far
                row.push(ForumAttendance.where(sadhak_profile: sp, is_attended: true).count)

                # Push member id
                row.push(member.id)

                # Push row in list
                members_list.push(row)

              end
            end

          end

        end

        if members_list.size > 0 and recipients.present?
          members_list.in_groups_of(excel_rows_limit, false) do |group|
            sheet_index += 1
            attachments = {}

            attachments["#{sheet_index}_#{info[:identifier]}_consolidated_forum_members_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = GenerateExcel.generate(rows: group, header: columns_for_member_list)

            UserMailer.send_email(from: info[:from], recipients: recipients, subject: "#{info[:identifier].try(:titleize)} Consolidated Members List #{sheet_index}- #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: attachments).deliver
            logger.info("#{info[:identifier].try(:titleize)} Consolidated forum members list sent to - #{recipients.to_sentence}.")
          end
        end
    rescue StandardError => e
      Rollbar.error(e)
    end

  end
end
