# Create Photo approval report excel
photo_approval_report_master = ReportMaster.find_by(report_name: 'photo_approval')

# Create Photo approval report excel
columns1 = %w(STATUS_CHANGED_DATE)

columns2 = %w(APPROVED_BY_SYID APPROVED_BY_NAME)

columns2_updated = %w(STATUS_CHANGED_BY_SYID STATUS_CHANGED_BY_NAME)

columns2.each_with_index do |c, i|
  rmf = ReportMasterField.find_by(field_name: c.downcase)
  rmf.update(field_name: columns2_updated[i].downcase)
end

columns1.each do |c|
  rmf = ReportMasterField.find_or_create_by(field_name: c.downcase)
  ReportMasterFieldAssociation.find_or_create_by(report_master_id: photo_approval_report_master.id, report_master_field_id: rmf.id)
end

photo_approval_report_master.reload.update_report_blocks


# Add email subject in global preferences
gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_approval_email_subject', alias_name: 'Photo and Photo ID Approval Email Subject')

gp.update(val: 'Photo and Photo ID Approved.')

gp = GlobalPreference.find_or_create_by(key: 'photo_and_photo_id_rejection_email_subject', alias_name: 'Photo and Photo ID Rejection Email Subject')

gp.update(val: 'Photo and Photo ID Rejected.')
