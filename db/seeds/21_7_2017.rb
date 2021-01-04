gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_email_subject')
gp.update(group_name: 'SadhakProfile' , input_type: 'text_area')


gp = GlobalPreference.find_or_create_by(key: 'banned_forum_sadhaks')
gp.update(group_name: 'SadhakProfile' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_email_subject')
gp.update(group_name: 'SadhakProfile' , input_type: 'text_area')


gp = GlobalPreference.find_or_create_by(key: 'india_clp_renewal_link')
gp.update(group_name: 'SyClub' , input_type: 'text_field')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_sms_text')
gp.update(group_name: 'SadhakProfile' , input_type: 'text_area')


gp = GlobalPreference.find_or_create_by(key: 'india_clp_validity')
gp.update(group_name: 'SyClub' , input_type: 'text_field')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_reasons')
gp.update(group_name: 'SadhakProfile' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'india_forum_summary_emails')
gp.update(group_name: 'SyClub' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_upload_guidelines')
gp.update(group_name: 'SadhakProfile' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'global_forum_summary_emails')
gp.update(group_name: 'SyClub' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'global_clp_renewal_link')
gp.update(group_name: 'SyClub' , input_type: 'text_field')


gp = GlobalPreference.find_or_create_by(key: 'india_event_summary_report')
gp.update(group_name: 'Event' , input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_email_text')
gp.update(group_name: 'SadhakProfile' , input_type: 'text_area')


gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_sms_text')
gp.update(group_name: 'SadhakProfile' , input_type: 'text_area')

gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_email_text')
gp.update(group_name: 'SadhakProfile', input_type: 'text_area' )


gp = GlobalPreference.find_or_create_by(key: 'india_clp_events')
gp.update(group_name: 'SyClub', input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'global_clp_events')
gp.update(group_name: 'SyClub', input_type: 'tagsinput')


gp = GlobalPreference.find_or_create_by(key: 'event_summary_report_email')
gp.update(group_name: 'Event', input_type: 'tagsinput')  


gp = GlobalPreference.find_or_create_by(key: 'global_clp_validity')
gp.update(group_name: 'SyClub', input_type: 'text_field')