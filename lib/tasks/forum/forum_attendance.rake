require "#{Rails.root}/app/models/concerns/common_helper"
namespace :forum do
  include CommonHelper

  def generate_random_color(colours = [])
    begin
      colour = '%06x' % (rand * 0xffffff)
      colour = "##{colour}"
    end while colours.include?(colour)
    colour
  end

  desc 'Send episode attendance as email to all board members if edited. Daily at 11:45 UTC'
  task :send_episode_attendance_if_edited, [:recipients] => :environment do |t, args|

    cc = args[:recipients] || []

    ForumAttendanceDetail.where('updated_at >= ? AND updated_at < ?', Time.now - 1.day, Time.now).includes({forum_attendances: [:sadhak_profile, {who_last_updated: [:sadhak_profile]}]}, :digital_asset, :sy_club).find_each(batch_size: 1) do |forum_attendance_detail|

      begin

        sy_club = forum_attendance_detail.sy_club

        board_member_emails = sy_club.try(:board_member_emails) || []

        digital_asset = forum_attendance_detail.digital_asset

        header = %w(EPISODE_NAME DATE_OF_EPISODE SYID FULL_NAME HAS_ATTENDED ATTENDACNE_MARKED_DATE LAST_ATTENDANCE_MARKED_BY)

        rows = []

        forum_attendance_detail.forum_attendances.order('is_current_forum_member DESC').each do |forum_attendance|

          sadhak_profile = forum_attendance.sadhak_profile

          row = []

          row << forum_attendance_detail.asset_name

          row << forum_attendance_detail.conducted_on

          row << sadhak_profile.try(:syid)

          row << sadhak_profile.try(:full_name)

          row << (forum_attendance.is_attended ? 'Present' : 'Absent')

          row << forum_attendance.updated_at.strftime('%Y-%m-%d')

          row << "#{forum_attendance.who_last_updated.try(:sadhak_profile).try(:full_name)}-#{forum_attendance.who_last_updated.try(:sadhak_profile).try(:syid)}"

          rows << row

        end

        from = GetSenderEmail.call(forum_attendance_detail.sy_club)

        h2_message = "Episode: #{digital_asset.try(:asset_name)} - Conducted On: #{forum_attendance_detail.conducted_on.strftime('%d-%m-%Y')} - #{sy_club.name} Attendance."

        sy_club.sadhak_profiles.each do |board_member|

          ApplicationMailer.send_email(from: from, recipients: board_member.email, cc: cc, subject: "Episode: #{digital_asset.asset_name} conducted on #{forum_attendance_detail.conducted_on.strftime('%d-%m-%Y')} on #{sy_club.name} attendance.",  forum_attendance_detail: forum_attendance_detail, h2_message: h2_message, attachments: Hash["#{forum_attendance_detail.conducted_on.strftime('%d-%m-%Y')}_episode_attendance.xls", GenerateExcel.generate(header: header, rows: rows)], template: 'send_episode_attendance_if_edited', board_member: board_member).deliver if board_member.email.to_s.is_valid_email?

        end

      rescue Exception => e
        Rails.logger.error("Rake::Task::send_episode_attendance_if_edited::Error - #{e.message}")
      end

    end
  end

  desc 'Send episode attendance as email to individual sadhak. Monthly on 1st at 11:50 UTC'
  task :send_episode_attendance_to_individual_sadhak, [:recipients] => :environment do |t, args|

    form_date = Date.today - 1.month

    to_date = Date.today

    header = %w(EPISODE_NAME TOTAL_CONDUCTED ATTENDED)

    cc = args[:recipients] || []

    SyClubMember.where(status: SyClubMember.statuses.approve).find_each(batch_size: 1) do |sy_club_member|

      sadhak_profile = sy_club_member.sadhak_profile

      unless sadhak_profile.try(:email).try(:is_valid_email?)

        sadhak_profile.send_sms_to_sadhak("NMS #{sadhak_profile.syid}-#{sadhak_profile.full_name}\nKindly update your email to receive monthly forum attendance report.")

        next

      end

      begin

        rows = []

        ForumAttendance.joins(:forum_attendance_detail).where(forum_attendance_details: {created_at: form_date...to_date}, forum_attendances: {sadhak_profile_id: sy_club_member.sadhak_profile_id}).uniq.group_by{|fa| fa.forum_attendance_detail.digital_asset}.each do |digital_asset, forum_attendances|

          row = []

          row << digital_asset.asset_name

          row << ForumAttendanceDetail.where(created_at: form_date...to_date, digital_asset: digital_asset, sy_club_id: sy_club_member.sy_club_id).count

          row << forum_attendances.select(&:is_attended).size

          rows << row

        end

      rescue Exception => e
        Rails.logger.error("Rake::Task::send_episode_attendance_to_individual_sadhak::Error - #{e.message}")
      end

      next if rows.size == 0

      from = GetSenderEmail.call(sadhak_profile)

      h2_message = "Please find forum attendance list attached from #{form_date.strftime('%d-%m-%Y')} to #{to_date.strftime('%d-%m-%Y')}."

      ApplicationMailer.send_email(from: from, recipients: sadhak_profile.email, cc: cc, subject: "#{sadhak_profile.syid}-#{sadhak_profile.full_name} Forum Attendance from #{form_date.strftime('%d-%m-%Y')} to #{to_date.strftime('%d-%m-%Y')}", sadhak_profile: sadhak_profile, attachments: Hash["attendance_sheet_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls", GenerateExcel.generate(header: header, rows: rows)], template: 'send_episode_attendance_to_individual_sadhak', h2_message: h2_message).deliver

    end
  end

  desc 'Send graphical episode attendance as email to Ashram. Every Monday at 11:40 UTC'
  task :send_graphical_attendance_report_to_ashram, [:recipients] => :environment do |t, args|

    begin

      chart_data = []

      s3 = Aws::S3::Client.new

      exit unless s3.present?

      bucket = s3.buckets[ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET']]

      exit unless bucket.exists?

      cc = args[:recipients] || []

      SyClub.joins(:address).where('sy_clubs.status = ? AND addresses.city_id IS NOT ?', SyClub.statuses.enabled, nil).pluck("sy_clubs.id", "addresses.city_id").group_by{|sy_club_id, city_id| city_id}.each do |city_id, sy_club_ids|

        city = DbCity.find_by_id(city_id)

        sy_club_ids = sy_club_ids.flatten.uniq - [city_id]

        next if !city.present? || sy_club_ids.size == 0

        SyClub.where(id: sy_club_ids).find_in_batches(batch_size: 20).with_index do |sy_clubs, i|

          g = Gruff::Bar.new('2000x2000')

          g.legend_font_size = 10

          g.legend_margin = 3

          g.legend_box_size = 5

          g.bar_spacing = 0.5

          g.title = "#{city.name} - Bar #{i+1}"

          g.title_font_size = 15

          g.theme_37signals

          g.x_axis_label = 'Forum(s)'

          g.y_axis_label = 'Value (Percentage)'

          is_empty = true

          colours = []

          sy_clubs.each do |sy_club|

            total_members = 0

            total_attended = 0

            ForumAttendanceDetail.where(sy_club: sy_club).find_each(batch_size: 1) do |forum_attendance_detail|

              total_members += forum_attendance_detail.forum_attendances.size

              total_attended += forum_attendance_detail.forum_attendances.select(&:is_attended).size

            end

            val = (total_members > 0 ? (total_attended/total_members.to_f): 0) * 100

            if val > 0

              colours << generate_random_color(colours)

              g.data(sy_club.name, [val], colours.last)

              is_empty = false

            end

          end

          next if is_empty

          chart_file_path = "#{Rails.root}/tmp/#{Random.new_seed.to_s}.png"

          g.write(chart_file_path)

          next unless File.exists?(chart_file_path)

          s3_file_path = "#{ENV['ENVIRONMENT']}/scripts/forum/send_graphical_attendance_report_to_ashram/#{File.basename(chart_file_path)}"

          # Upload file to s3
          s3_file = bucket.objects[s3_file_path].write(file: chart_file_path, acl: 'public-read', content_type: MIME::Types.type_for(chart_file_path).first.content_type)

          chart_data << s3_file.public_url.to_s

          File.delete(chart_file_path)

        end

      end

      h2_message = "Graphical Attendance By City."

      ApplicationMailer.send_email(recipients: ENV['DEVELOPMENT_RESP'].extract_valid_emails, cc: cc, subject: "Graphical Attendance By City", data: chart_data, template: 'send_graphical_attendance_report_to_ashram', h2_message: h2_message).deliver if chart_data.size > 0

    rescue => e
      Rollbar.error(e)
    end

  end

  desc 'Send bar chart report of each sadhak as email to all board members. In every 3 months at 11:45 UTC'
  task :send_graphical_report_of_each_sadhak_attended_to_board_members, [:recipients] => :environment do |t, args|

    form_date = Date.today - 3.months

    to_date = Date.today

    s3 = Aws::S3::Client.new

    exit unless s3.present?

    bucket = s3.buckets[ENV['ACTIVITY_DIGITAL_ASSETS_BUCKET']]

    exit unless bucket.exists?

    cc = args[:recipients] || []

    SyClub.where(status: SyClub.statuses.enabled).find_each(batch_size: 1) do |sy_club|

      begin

        sadhak_profile_ids = ForumAttendance.joins(:forum_attendance_detail).where(forum_attendance_details: {created_at: form_date...to_date, sy_club_id: sy_club.id}).pluck('forum_attendances.sadhak_profile_id').uniq

        sadhak_id_with_episode_attended_count = ForumAttendance.joins(:forum_attendance_detail).where(forum_attendance_details: {created_at: form_date...to_date, sy_club_id: sy_club.id}, forum_attendances: {is_attended: true}).select("forum_attendances.sadhak_profile_id, forum_attendances.is_attended").group("forum_attendances.sadhak_profile_id").order("forum_attendances.sadhak_profile_id").size

        sadhak_profile_ids_with_0_attendance = sadhak_profile_ids - sadhak_id_with_episode_attended_count.keys

        sadhak_profile_ids_with_0_attendance.each{|sadhak_profile_id| sadhak_id_with_episode_attended_count[sadhak_profile_id] = 0 }

        next if sadhak_id_with_episode_attended_count.size == 0

        chart_data = []

        sadhak_id_with_episode_attended_count.sort_by{|k, v| k.to_i }.in_groups_of(20, false).each_with_index do |group, i|

          g = Gruff::Bar.new('2000x2000')

          g.legend_font_size = 10

          g.legend_margin = 3

          g.legend_box_size = 5

          g.bar_spacing = 0.5

          g.title = "#{sy_club.name} - Bar #{i+1}"

          g.title_font_size = 15

          g.theme_37signals

          g.x_axis_label = 'SYID'

          g.y_axis_label = 'Value (Numeric)'

          # g.show_labels_for_bar_values = true

          # g.label_formatting = "%.0f"

          g.y_axis_increment = 1

          colours = []

          # (1..20).to_a.each_with_index do |v, i|

          #   colours << generate_random_color(colours)

          #   g.data("SY#{i}", [rand(10)], colours.last)

          # end

          # g.write(chart_file_path)

          colours = []

          group.each do |sadhak_profile_id, episode_attended|

            colours << generate_random_color(colours)

            g.data("SY#{sadhak_profile_id}", [episode_attended], colours.last)

          end

          chart_file_path = "#{Rails.root}/tmp/#{Random.new_seed.to_s}.png"

          g.write(chart_file_path)

          next unless File.exists?(chart_file_path)

          s3_file_path = "#{ENV['ENVIRONMENT']}/scripts/forum/send_graphical_report_of_each_sadhak_attended_to_board_members/#{File.basename(chart_file_path)}"

          # Upload file to s3
          s3_file = bucket.objects[s3_file_path].write(file: chart_file_path, acl: 'public-read', content_type: MIME::Types.type_for(chart_file_path).first.content_type)

          chart_data << s3_file.public_url.to_s

          File.delete(chart_file_path)

        end

        next if chart_data.size == 0

        from = GetSenderEmail.call(sy_club)

        h2_message = "Graphical Report of #{sy_club.name} members attendance from #{form_date.strftime('%d-%m-%Y')} to #{to_date.strftime('%d-%m-%Y')}"

        sy_club.board_member_emails.each do |board_member_email|

          ApplicationMailer.send_email(from: from, recipients: board_member_email, cc: cc, subject: "Graphical Attendance from #{form_date.strftime('%d-%m-%Y')} to #{to_date.strftime('%d-%m-%Y')} of #{sy_club.name}", data: chart_data, template: 'send_graphical_report_of_each_sadhak_attended_to_board_members', h2_message: h2_message).deliver

        end

      rescue => e
        Rollbar.error(e)
      end

    end

  end

  desc 'Send consolidated forum attendance report. Daily at 00:00 UTC'
  task :consolidated_forum_attendance_report, [:region, :recipients] => :environment do |t, args|

    begin

      recipients = args[:recipients].to_s.split(' ') || []

      rows = []

      header = %w(FORUM_ATTENDANCE_DETAIL_ID FORUM_ID FORUM_NAME CURRENTLY_REGISTERED_FORUM_MEMBERS_COUNT EPISODE_NAME DATE_OF_MARKING_ATTENDANCE ATTENDANCE_MARKED_BY_SYID ATTENDANCE_MARKED_BY_NAME REGISTERED_FORUM_MEMBERS_COUNT_AT_TIME_OF_ATTENDANCE NO_OF_FORUM_MEMBERS_ABSENT NO_OF_FORUM_MEMBERS_PRESENT NUMBER_OF_OUTSIDERS_PRESENT TOTAL_ATTENDED_COUNT PRESENT_MEMBERS_PERCENTAGE)

      # Collect role id with role name
      club_roles = SyClubUserRole.all.collect{|r| {id: r.id, role_name: r.role_name.upcase}}

      columns_for_board_members = %w(SYID FULLNAME)

      # Create excel header like: PRESIDENT_SYID etc.
      club_roles.each do |m_role|

        columns_for_board_members.each do |b_detail_column|

          header.push(m_role[:role_name] + '_' + b_detail_column)

        end

      end

      from =  'support@absclp.com'

      if args[:region].present?

        if args[:region].downcase == 'india'

          from = 'registration@shivyogindia.com'

          sy_clubs = SyClub.joins(:address).where(addresses: {country_id: 113}).order('id ASC')

          recipients += GlobalPreference.unscoped.where(key: 'india_forum_summary_emails').last.try(:val).to_s.split(',')

        elsif args[:region].downcase == 'global'

          sy_clubs = SyClub.joins(:address).where.not(addresses: {country_id: [113, nil]}).order('id ASC')

          recipients += GlobalPreference.unscoped.where(key: 'global_forum_summary_emails').last.try(:val).to_s.split(',')

        else

          sy_clubs = SyClub

        end

      else

        sy_clubs = SyClub

      end

      # Collect forum attendance details forum wise.
      sy_clubs.find_each(batch_size: 1) do |sy_club|

        board_member_details = sy_club.sy_club_sadhak_profile_associations.select{|a| a.sy_club_user_role_id != nil}.collect do |s|

          {
            syid: s.try(:sadhak_profile).syid,
            fullname: s.try(:sadhak_profile).try(:full_name).try(:titleize),
            sy_club_user_role_id: s.sy_club_user_role_id
          }

        end

        sy_club.forum_attendance_details.find_each(batch_size: 1) do |forum_attendance_detail|

          row = []

          row << forum_attendance_detail.id

          row << sy_club.id

          row << sy_club.name

          row << sy_club.approved_members.count

          row << forum_attendance_detail.asset_name

          row << forum_attendance_detail.conducted_on.strftime('%Y-%m-%d %I:%M:%S %p')

          row << forum_attendance_detail.who_last_updated_syid

          row << forum_attendance_detail.who_last_updated_full_name

          row << forum_attendance_detail.forum_attendances.where(is_current_forum_member: true).count

          row << forum_attendance_detail.forum_attendances.where(is_current_forum_member: true, is_attended: false).count

          row << forum_attendance_detail.forum_attendances.where(is_current_forum_member: true, is_attended: true).count

          row << forum_attendance_detail.forum_attendances.where(is_current_forum_member: false, is_attended: true).count

          row << forum_attendance_detail.forum_attendances.where(is_attended: true).count

          row << forum_attendance_detail.attendance_percentage

          club_roles.each do |club_role|

            role = (board_member_details.find{|c| c[:sy_club_user_role_id] == club_role[:id]} || {})

            columns_for_board_members.each do |b_detail_column|

              row << (role.present? ? role[b_detail_column.downcase.to_sym] : '')

            end

          end

          rows << row

        end

      end

      sheet_index = 0

      excel_rows_limit = (7e6 / (header.size * 16)).to_i

      rows.size > 0 && rows.in_groups_of(excel_rows_limit, false) do |group|

        sheet_index += 1

        attachments = {}

        attachments["#{sheet_index}_#{args[:region]}_consolidated_forum_attendance_report_#{Time.now.strftime('%d%m%Y%H%M%S%N')}.xls"] = GenerateExcel.generate(rows: group, header: header)

        begin
          ApplicationMailer.send_email(from: from, recipients: recipients, subject: "Consolidated Forum Attendance List #{sheet_index}- #{Time.now.strftime('%d%m%Y%H%M%S%N')}", attachments: attachments).deliver if recipients.size > 0
          sleep 10
        rescue => e
          Rollbar.error(e)
        end

      end

    rescue => e
      Rollbar.error(e)
    end

  end

end
