namespace :questionnaire_form do
  desc 'Daily Send Questionnaire form report'
  task daily_send_questionnaire_form_report: :environment do
    begin
      header = %w(SADHAK_PROFILE_ID EVENT_ID PHONE EMAIL_ID EDUCATION PROFESSION/SKILLS ARE_YOU_A_DOCTOR? IF_YES,_WHAT_IS_YOUR_SPECIALIZATION? ARE_YOU_PRACTICING_ANY_OF_THE_FOLLOWING_OR_OTHER_ALTERNATIVE_MEDICINE_MODALITIES? SHIVIR_ATTENDED IF_YOU_ATTENDED_ANY_OTHER_SHIVIR,_PLEASE_MENTION_ITS_NAME ARE_YOU_INTERESTED_IN_BECOMING_SHIV_YOG_COSMIC_THERAPIST_TRAINER)
      rows = row = []
      recipients = GlobalPreference.get_value_of('questionnaire_form_recipients').split(',') || ENV['DEVELOPMENT_RESP']
      date = Date.today
      questionnaires = EventSadhakQuestionnaire.where("created_at >= ? AND created_at <= ?", date.beginning_of_day, date.end_of_day).order('event_id')
      questionnaires.each do |questionnaire|
        row = []
        data = questionnaire.data.with_indifferent_access
          row.push(questionnaire.sadhak_profile_id)
          row.push(questionnaire.event_id)
          row.push(data[:phone] || '')
          row.push(data[:email_id] || '')
          row.push(data[:education] || '')
          row.push(data[:profession_skills] || '')
          row.push(data[:is_doctor] || '')
          row.push(data[:specialization] || '')
          row.push((data[:medicine_modalities] || '').join(', '))
          row.push((data[:attended_shivir] || '').join(', '))
          row.push(data[:attended_other_shivir] || '')
          row.push(data[:can_be_therapist] || '')
          rows.push(row)
      end
      attachments = {}
      file_name = "questionnaire_form_report-#{DateTime.now.strftime('%F %T')}"
      file = EventRegistration.generate_excel_file(rows: rows, header: header)
      attachments["#{file_name}.xls"] = file
      Attachment.upload_file(file_name: "#{file_name}.xls", content: file, is_secure: false, bucket_name: ENV['ATTACHMENT_BUCKET'], attachable_id: EventSadhakQuestionnaire.last.try(:id) || (rand * 1000).to_i, attachable_type: "EventSadhakQuestionnaire", file_type: 'application/vnd.ms-excel', prefix: "#{ENV['ENVIRONMENT']}/scripts/questionnaire_form_reports")
      ApplicationMailer.send_email(recipients: recipients, subject: "Daily Questionnaire form report: File - #{file_name}", attachments: attachments).deliver_now
    rescue Exception => e
      Rails.logger.error("Some error occured in daily_send_questionnaire_form_report: #{e.message}")
      EventRegistration.notify_exception(e)
    end
  end
end